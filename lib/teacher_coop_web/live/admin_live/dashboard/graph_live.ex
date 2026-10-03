defmodule TeacherCoopWeb.AdminLive.Graph do
  use TeacherCoopWeb, :live_component

  @impl true
  def render(assigns) do
    ~H"""
    <section id={@id} class="flex-1 w-full">
      <div :if={@display_graph} class="shadow-xl p-4 bg-base-200 rounded-xl text-center">
        <div>
          {@graph}
        </div>
      </div>
      <div :if={!@display_graph} class="shadow-xl p-4 bg-base-200 rounded-xl text-center">
        {gettext("No data")}
      </div>
    </section>
    """
  end

  @impl true
  def update(assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign(:display_graph, assigns.data != [])
     |> assign(:graph, make_graph(assigns.data, assigns.title))}
  end

  defp make_graph(data, _) when data == [], do: nil

  defp make_graph(data, title) when length(data) != 0 do
    dataset = Contex.Dataset.new(data, ["x", "y"])
    chart = Contex.LinePlot.new(dataset)

    Contex.Plot.new(600, 400, chart)
    |> Contex.Plot.titles(title, "")
    |> Contex.Plot.to_svg()
  end
end
