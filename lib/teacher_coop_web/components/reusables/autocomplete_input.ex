defmodule TeacherCoopWeb.Reusables.AutocompleteInput do
  use TeacherCoopWeb, :live_component

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <input
        type="text"
        id={@name <> "-input-autocomplete"}
        name="input-autocomplete"
        value={@input_value}
        class="w-full input"
        phx-hook={@allow_input_edit && ".SetValue"}
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
      <div
        :if={@autocomplete_list != []}
        class="flex flex-col gap-2 border-2 absolute rounded-md z-10"
        phx-click-away={"close-#{@name}-autocomplete"}
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
                detail: %{id: @name <> "-input-autocomplete", value: ""}
              )
              |> JS.push("select-entry", value: %{id: entry.id, value: entry.value})
            }
          >
            {entry.value}
          </li>
        </ul>
      </div>

      <script :if={@allow_input_edit} :type={Phoenix.LiveView.ColocatedHook} name=".SetValue">
        export default {
          mounted() {
            this.handleEvent("set-value", ({value}) => {
              this.el.value = value
            })
          }
        }
      </script>
    </div>
    """
  end

  @impl true
  def handle_event("select-entry", %{"id" => id, "value" => value}, socket) do
    user_submit(%{id: id, value: value}, socket)
  end

  def handle_event("user-typing", %{"input-autocomplete" => value}, socket) do
    socket.assigns.on_user_typing.(value)
    {:noreply, socket}
  end

  def handle_event("user-navigate", %{"key" => key, "value" => user_input}, socket) do
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
        value = Enum.at(socket.assigns.autocomplete_list, idx)
        user_submit(value, socket)

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
