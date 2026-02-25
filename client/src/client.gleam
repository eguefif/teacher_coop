import lustre
import lustre/effect.{type Effect}
import lustre/element.{type Element}
import lustre/element/html
import visitor/visitor

pub fn main() -> Nil {
  let app = lustre.application(init, update, view)

  let assert Ok(_) = visitor.register()
  let assert Ok(_) = lustre.start(app, "#app", Nil)

  Nil
}

type Model {
  Visitor
  User
}

type Msg {
  VisitorLogin
}

fn init(_args) -> #(Model, Effect(Msg)) {
  #(Visitor, effect.none())
}

fn update(model: Model, msg: Msg) -> #(Model, Effect(Msg)) {
  case msg {
    VisitorLogin -> {
      case model {
        Visitor -> #(User, effect.none())
        User -> #(model, effect.none())
      }
    }
  }
}

fn view(model: Model) -> Element(Msg) {
  html.html([], [head(model), body(model)])
}

fn head(_model: Model) -> Element(Msg) {
  html.head([], [
    html.title([], "Teacher Coop"),
  ])
}

fn body(model: Model) -> Element(Msg) {
  case model {
    Visitor -> {
      visitor.element()
    }
    User -> {
      html.div([], [html.text("Welcome back!")])
    }
  }
}
