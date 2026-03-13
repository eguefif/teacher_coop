import gleam/dynamic/decode
import lustre/attribute
import lustre/element.{type Element}
import lustre/element/html
import lustre/event

pub fn overlay(msg_outside: msg, no_action: msg) -> Element(msg) {
  html.div(
    [
      attribute.attribute(
        "style",
        "
    z-index: 0;
    position: fixed;
    top: 0;
    left: 0;
    width: 100%;
    height: 100%;
  ",
      ),
      event.on("click", {
        use current_target <- decode.then(decode.at(
          ["currentTarget", "id"],
          decode.string,
        ))
        use target <- decode.then(decode.at(["target", "id"], decode.string))
        decode.success(case current_target == target {
          True -> msg_outside
          False -> no_action
        })
      }),
    ],
    [],
  )
}
