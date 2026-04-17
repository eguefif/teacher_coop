defmodule TeacherCoopWeb.Reusables.AutocompleteInput do
  use TeacherCoopWeb, :live_component

  @impl true
  def update(assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign_new(:current_value, fn -> "" end)
     |> assign_new(:on_add, fn -> nil end)}
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
          value={@input_value}
          class="w-full input"
          phx-hook={if @allow_input_edit, do: "SetValue"}
          phx-change="user-typing"
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
          :if={@on_add}
          type="button"
          phx-click="add-item"
          phx-target={@myself}
          aria-label={gettext("Add item")}
        >
          <.icon name="hero-plus-circle" class="size-8 shrink-0 text-gray-400 cursor-pointer" />
        </button>
      </div>
      <div
        :if={@autocomplete_list != []}
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
    socket.assigns.on_close.()
    {:noreply, assign(socket, :autocomplete_list, [])}
  end

  def handle_event("select-entry", %{"id" => id, "value" => value}, socket) do
    case socket.assigns.allow_input_edit do
      true ->
        {:noreply,
         socket
         |> assign(:current_value, value)
         |> assign(:autocomplete_list, [])
         |> push_event("set-value", %{value: value})}

      false ->
        user_submit(%{id: id, value: value}, socket)
    end
  end

  def handle_event("user-typing", params, socket) do
    value = params[socket.assigns.name] || ""
    socket.assigns.on_user_typing.(value)
    {:noreply, assign(socket, :current_value, value)}
  end

  def handle_event("add-item", _, socket) do
    socket.assigns.on_add.(socket.assigns.current_value)
    {:noreply, assign(socket, :current_value, "")}
  end

  def handle_event("user-navigate", %{"key" => key}, socket) do
    max_idx = Enum.count(socket.assigns.autocomplete_list)

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
        case socket.assigns.allow_input_edit do
          true ->
            {:noreply, socket}

          false ->
            value = Enum.at(socket.assigns.autocomplete_list, idx)
            user_submit(value, socket)
        end

      {"Escape", _} ->
        {:noreply, assign(socket, :nav, nil) |> assign(:autocomplete_list, [])}

      _ ->
        {:noreply, socket}
    end
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
