import lustre/effect.{type Effect}
import lustre/element.{type Element}
import lustre/element/html

// Model ---------------------------------------------------------------------------------------

pub type Model {
  Admin
}

pub fn init() -> Model {
  Admin
}

// Update ---------------------------------------------------------------------------------------

pub type Msg {
  Nothing
}

pub fn update(model: Model, msg: Msg) -> #(Model, Effect(Msg)) {
  case msg {
    Nothing -> #(model, effect.none())
  }
}

// View ---------------------------------------------------------------------------------------

pub fn view() -> Element(msg) {
  html.div([], [html.text("Admin")])
}
