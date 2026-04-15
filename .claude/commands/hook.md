# Writing a LiveView Hook

Use this guide when adding a JavaScript hook to a Phoenix LiveView component in this project.

## Two approaches

### 1. Colocated hook (preferred — keeps JS next to the component)

Define the hook directly inside the `~H"""` template of the **function component** that uses it:

```elixir
def my_component(assigns) do
  ~H"""
  <input phx-hook=".MyHook" id="my-el" ... />
  <script :type={Phoenix.LiveView.ColocatedHook} name=".MyHook">
    export default {
      mounted() {
        // this.el is the DOM element with phx-hook
      }
    }
  </script>
  """
end
```

Rules:
- The `<script>` tag needs `:type={Phoenix.LiveView.ColocatedHook}`
- The name **must start with a dot**: `.MyHook`
- `phx-hook` on the element must also use the dot: `phx-hook=".MyHook"`
- The hook is automatically picked up by `...colocatedHooks` in `app.js` — no manual registration needed
- The element must have a unique `id` attribute

### 2. Global hook (in app.js)

For hooks shared across multiple components, add them to `assets/js/app.js`:

```javascript
const hooks = {
  ...colocatedHooks,
  MyHook: {
    mounted() {
      // this.el is the DOM element
    }
  }
}
// pass `hooks` to LiveSocket instead of `{...colocatedHooks}`
```

Reference with `phx-hook="MyHook"` (no dot for global hooks).

## Hook lifecycle callbacks

```javascript
export default {
  mounted()     { /* element added to DOM */ },
  updated()     { /* element patched by LiveView */ },
  destroyed()   { /* element removed from DOM */ },
  disconnected(){ /* socket disconnected */ },
  reconnected() { /* socket reconnected */ },
}
```

## Receiving server push_event

From the server:
```elixir
{:noreply, push_event(socket, "my-event", %{key: "value"})}
```

In the hook:
```javascript
mounted() {
  this.handleEvent("my-event", ({key}) => {
    // handle the event
  })
}
```

## Pushing events to the server

```javascript
this.pushEvent("my-server-event", {key: "value"})
// or with a reply callback:
this.pushEvent("my-event", {}, (reply) => { console.log(reply) })
```

## Common pattern in this project: force-update a focused input

The `.SetValue` hook in `curriculum_input` is the reference example:

```elixir
# Server side
{:noreply, push_event(socket, "set-value", %{value: new_value})}
```

```javascript
// Colocated hook
<script :type={Phoenix.LiveView.ColocatedHook} name=".SetValue">
  export default {
    mounted() {
      this.handleEvent("set-value", ({value}) => {
        this.el.value = value
      })
    }
  }
</script>
```

This is needed because LiveView will not update the value of a focused input during re-renders, even with `value={@assign}` set.
