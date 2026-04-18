defmodule TeacherCoopWeb.Reusables.AutocompleteInput do
  use TeacherCoopWeb, :live_component

  # Autocomplete text input live component.
  #
  # Required assigns:
  #   - id, name               — must be unique per page
  #   - autocomplete_list      — list of %{id: any, value: string} suggestions;
  #                              kept in the parent's assigns and updated in the
  #                              handle_info triggered by on_user_typing
  #   - on_user_typing         — fn(value) called on each keystroke; must send a
  #                              message to the parent (via send/2) so handle_info
  #                              can query suggestions and update autocomplete_list
  #   - on_autocomplete_submit — fn(%{id, value}) called when an entry is confirmed
  #
  # Optional assigns:
  #   - allow_input_edit — boolean, default false (see modes below)
  #
  # Modes:
  #   false (default) — select-only. The user picks from suggestions; the input
  #                     clears after selection. Suited for tags or constrained fields.
  #   true            — editable. The user may type freely or pick a suggestion to
  #                     pre-fill the input, then confirm with "+" or Enter.
  #                     Suited for fields that accept custom values (e.g. curriculum).
  #
  # JS hook:
  #   Requires the `SetValue` hook in assets/js/app.js. It handles two server events:
  #   "set-value" (fill input after suggestion pick) and "reset-value" (clear after submit).
  #
  # Example:
  #
  #   # In render/1:
  #   <.live_component
  #     module={Reusables.AutocompleteInput}
  #     id="tag-input"
  #     name="tag-input"
  #     autocomplete_list={@autocomplete_tags}
  #     on_user_typing={fn value -> send(self(), {:tag_typing, value}) end}
  #     on_autocomplete_submit={fn item -> send(self(), {:add_tag, item}) end}
  #   />
  #
  #   # In the parent LiveView:
  #   def handle_info({:tag_typing, value}, socket) do
  #     tags = MyApp.search_tags(value)
  #     {:noreply, assign(socket, :autocomplete_tags, tags)}
  #   end
  #
  #   def handle_info({:add_tag, %{value: tag}}, socket) do
  #     {:noreply, assign(socket, :tags, socket.assigns.tags ++ [tag])}
  #   end

  @impl true
  def update(assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign_new(:current_value, fn -> "" end)
     |> assign_new(:allow_input_edit, fn -> false end)
     |> assign(:display_autocomplete, true)
     |> assign(:nav, nil)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <div class="flex flex-row gap-2">
        <input
          type="text"
          id={@name <> "-input-autocomplete"}
          name={@name}
          value={@current_value}
          class="w-full input"
          phx-hook="SetValue"
          phx-focus="display-autocomplete"
          phx-keyup="user-typing"
          phx-keydown="user-navigate"
          phx-target={@myself}
          onkeydown="if(event.key==='Enter'){event.preventDefault();}"
          role="combobox"
          aria-expanded={@autocomplete_list != []}
          aria-autocomplete="list"
          aria-controls={@name <> "-listbox"}
          aria-activedescendant={@nav && "#{@name}-option-#{@nav}"}
        />
        <button
          :if={@allow_input_edit}
          type="button"
          phx-click="add-item"
          phx-target={@myself}
          aria-label={gettext("Add item")}
        >
          <.icon name="hero-plus-circle" class="size-8 shrink-0 text-gray-400 cursor-pointer" />
        </button>
      </div>
      <div
        :if={@autocomplete_list != [] && @display_autocomplete}
        class="flex flex-col gap-2 border-2 absolute rounded-md z-10"
        phx-click-away="close-autocomplete"
        phx-target={@myself}
      >
        <ul class="list bg-base-100 rounded-box shadow-md" role="listbox" id={"#{@name}-listbox"}>
          <li
            :for={{entry, index} <- Enum.with_index(@autocomplete_list)}
            id={"#{@name}-option-#{index}"}
            role="option"
            aria-selected={@nav == index}
            tabindex="0"
            phx-target={@myself}
            class={["list-row hover:bg-primary", @nav == index && "bg-primary"]}
            phx-click={
              JS.dispatch("phx:set-input-value",
                detail: %{
                  id: @name <> "-input-autocomplete",
                  value: if(@allow_input_edit, do: entry.value, else: "")
                }
              )
              |> JS.push("select-entry", value: %{id: entry.id, value: entry.value})
            }
          >
            {entry.value}
          </li>
        </ul>
      </div>
    </div>
    """
  end

  @impl true
  def handle_event("close-autocomplete", _, socket) do
    {:noreply, assign(socket, :display_autocomplete, false)}
  end

  def handle_event("display-autocomplete", _, socket) do
    {:noreply, assign(socket, :display_autocomplete, true)}
  end

  def handle_event("select-entry", %{"id" => id, "value" => value}, socket) do
    case socket.assigns.allow_input_edit do
      true ->
        select_entry_when_allow_input_edit(value, socket)

      false ->
        user_submit(%{id: id, value: value}, socket)
    end
  end

  def handle_event("user-typing", %{"value" => value}, socket) do
    socket.assigns.on_user_typing.(value)
    {:noreply, assign(socket, :current_value, value)}
  end

  def handle_event("add-item", _, socket) do
    user_submit(
      %{id: nil, value: socket.assigns.current_value},
      socket
      |> assign(:current_value, "")
      |> push_event("reset-value", %{})
    )
  end

  def handle_event("user-navigate", %{"key" => key}, socket) do
    max_idx = Enum.count(socket.assigns.autocomplete_list)

    # TODO: add tab navigation
    case {key, socket.assigns.nav} do
      {"ArrowUp", nil} ->
        {:noreply, assign(socket, :nav, max_idx - 1)}

      {"ArrowDown", nil} ->
        {:noreply, assign(socket, :nav, 0)}

      {"ArrowUp", idx} ->
        {:noreply, assign(socket, :nav, calculate_new_nav(idx, max_idx, "up"))}

      {"ArrowDown", idx} ->
        {:noreply, assign(socket, :nav, calculate_new_nav(idx, max_idx, "down"))}

      {"Enter", idx} when not is_nil(idx) ->
        value = Enum.at(socket.assigns.autocomplete_list, idx)

        case socket.assigns.allow_input_edit do
          true ->
            select_entry_when_allow_input_edit(
              Map.fetch!(value, :value),
              socket
              |> assign(:nav, nil)
            )

          false ->
            user_submit(
              value,
              socket
              |> assign(:nav, nil)
              |> push_event("reset-value", %{})
            )
        end

      {"Enter", nil} ->
        user_submit(
          %{id: nil, value: socket.assigns.current_value},
          socket
          |> assign(:current_value, "")
          |> push_event("reset-value", %{})
        )

      {"Escape", _} ->
        {:noreply, assign(socket, :nav, nil) |> assign(:autocomplete_list, [])}

      _ ->
        {:noreply, socket}
    end
  end

  def select_entry_when_allow_input_edit(value, socket) do
    {:noreply,
     socket
     |> assign(:current_value, value)
     |> assign(:autocomplete_list, [])
     |> assign(:display_autocomplete, false)
     |> push_event("set-value", %{value: value})}
  end

  def user_submit(%{id: id, value: value}, socket) do
    socket.assigns.on_autocomplete_submit.(%{id: id, value: value})
    {:noreply, socket |> assign(:autocomplete_list, [])}
  end

  defp calculate_new_nav(idx, max_idx, "down") when idx + 1 == max_idx, do: 0
  defp calculate_new_nav(idx, _, "down"), do: idx + 1
  defp calculate_new_nav(idx, max_idx, "up") when idx - 1 < 0, do: max_idx - 1
  defp calculate_new_nav(idx, _, "up"), do: idx - 1
end
