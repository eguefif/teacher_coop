defmodule TeacherCoopWeb.AdminLive.BarGraph do
  use TeacherCoopWeb, :live_component
  alias VegaLite, as: Vl

  @impl true
  def render(assigns) do
    ~H"""
    <section id={@id} class="flex-1 w-full">
      <div class="shadow-xl p-4 bg-base-200 rounded-xl text-center">
        <div
          id={"#{@id}-chart"}
          phx-hook=".Graph"
          phx-update="ignore"
          data-spec={@spec}
        >
        </div>

        <script :type={Phoenix.LiveView.ColocatedHook} name=".Graph">
          import vegaEmbed from "vega-embed"

          function resolveCssColor(name) {
            const probe = document.createElement("span")
            probe.style.color = `var(${name})`
            probe.style.display = "none"
            document.body.appendChild(probe)
            const value = getComputedStyle(probe).color
            probe.remove()
            return value
          }

          export default {
            mounted() {
              this.draw()

              // Redraw when the DaisyUI theme changes so colors stay in sync.
              this.themeObserver = new MutationObserver(() => this.draw())
              this.themeObserver.observe(document.documentElement, {
                attributes: true,
                attributeFilter: ["data-theme", "class"]
              })
            },
            updated() {
              this.draw()
            },
            destroyed() {
              this.themeObserver?.disconnect()
              this.view?.finalize()
            },
            async draw() {
              const spec = JSON.parse(this.el.dataset.spec)

              // Theme colors are in the bundle, we cannot resolve them server side.
              // The following code allow to use theme colors.
              const lineColor = resolveCssColor("--color-primary")
              const textColor = resolveCssColor("--color-base-content")

              spec.mark = { ...spec.mark, color: lineColor }
              spec.config = spec.config || {}
              spec.config.title = { ...spec.config.title, color: textColor }
              spec.config.axis = { ...spec.config.axis, labelColor: textColor, titleColor: textColor }

              this.view?.finalize()
              const { view } = await vegaEmbed(this.el, spec, {actions: false })
              this.view = view
            }
          }
        </script>
      </div>
    </section>
    """
  end

  @impl true
  def update(assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign(:spec, make_graph(assigns.data, assigns.title) |> Jason.encode!())}
  end

  defp make_graph(data, title) do
    Vl.new(
      height: 100,
      background: "transparent",
      padding: [left: 6, right: 6, top: 8, bottom: 4],
      title: [
        text: title,
        anchor: :start,
        font_size: 18,
        font_weight: :normal,
        offset: 12
      ]
    )
    |> Vl.config(axis: [grid: false], view: [stroke: nil])
    |> Vl.data_from_values(data)
    |> Vl.mark(:bar, filled: true, width: [band: 0.8])
    |> Vl.encode_field(:x, "x",
      type: :ordinal,
      axis: [title: nil, label_overlap: true],
      scale: [padding_inner: 0, padding_outer: 0]
    )
    |> Vl.encode_field(:y, "y", type: :quantitative, axis: [title: nil])
    |> Vl.to_spec()
  end
end
