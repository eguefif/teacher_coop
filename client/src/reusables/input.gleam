import gleam/option.{type Option, None, Some}
import gleam/string
import lustre/attribute
import lustre/element.{type Element}
import lustre/element/html
import lustre/event

pub fn input(
  text: String,
  error: String,
  is_valid is_valid: Bool,
  on_focus on_focus: fn(String) -> msg,
  on_blur on_blur: Option(msg),
  is type_: String,
  name name: String,
  label label: String,
) -> Element(msg) {
  let has_error = string.length(error) > 0
  let has_input = string.length(text) > 0
  let input_class = case is_valid, has_error, has_input {
    _, True, True -> "input-error"
    True, False, True -> "input-valid"
    _, _, _ -> ""
  }

  html.div([attribute.class("input-container")], [
    input_style(),
    html.label([attribute.for(name)], [
      html.text(label),
    ]),
    html.div([attribute.class("input-row")], [
      html.input([
        event.on_input(on_focus),
        event.on_input(on_focus),
        case on_blur {
          Some(on_blur) -> event.on_blur(on_blur)
          None -> attribute.none()
        },
        attribute.type_(type_),
        attribute.id(name),
        attribute.value(text),
        attribute.class(input_class),
      ]),
      html.p(
        [
          attribute.class(case is_valid && has_input {
            True -> "input-valid-message visible"
            False -> "input-valid-message"
          }),
        ],
        [],
      ),
      html.div(
        [
          attribute.class(case has_error && has_input {
            True -> "input-error-message visible"
            False -> "input-error-message"
          }),
        ],
        [html.text(error)],
      ),
    ]),
  ])
}

fn input_style() -> Element(msg) {
  html.style(
    [],
    "
    .input-container {
      --input-container-bottom-padding: 40px;
      --input-text-size: 1rem;
      display: flex;
      width: var(--input-width);
      flex-direction: column;
      gap: 4px;
      padding-bottom: var(--input-container-bottom-padding);
    }
    .input-row {
      position: relative;
      display: flex;
      width: var(--input-width);
      flex-direction: row;
      align-items: center;
    }

      input.input-valid,
      textarea.input-valid {
        border-color: var(--color-success);
      }

      input.input-valid:focus,
      textarea.input-valid:focus {
        border-color: var(--color-success);
        /* TODO: use css variable */
        box-shadow: 0 0 0 3px rgba(76, 175, 130, 0.3);
      }

      input.input-error,
      textarea.input-error {
        border-color: var(--color-danger);
      }

      input.input-error:focus,
      textarea.input-error:focus {
        border-color: var(--color-danger);
        /* TODO: use css variable */
        box-shadow: 0 0 0 3px rgba(232, 95, 79, 0.3);
      }

      .input-error-message {
        position: absolute;
        bottom: -34px;
        left: 0;
        width: 100%;
        height: 28px;
        font-size: 0.9rem;
        margin: 0;
        visibility: hidden;
        text-align: center;
        color: var(--color-danger);
      }

      .input-error-message.visible {
        visibility: visible;
      }

      .input-error-message.visible::before {
        content: \"\u{26A0} \";
      }

      .input-valid-message {
        position: absolute;
        right: -1.5rem;
        top: 50%;
        transform: translateY(-50%);
        font-size: 1rem;
        margin: 0;
        visibility: hidden;
        color: var(--color-success);
      }

      .input-valid-message.visible {
        visibility: visible;
      }

      .input-valid-message.visible::before {
        content: \"\u{2713}\";
      }
    ",
  )
}
