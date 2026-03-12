//// Display a search input with autocomplete
////
//// WHen a user type, after a three letters, search kick-off
//// Results are displayed in a dropdown poper and are selectable.
//// The the user need to choose a result to complete the input
////
//// Attributes
////      * fn(search) -> List(String)
////      * j

import gleam/dynamic/decode
import gleam/io
import gleam/json
import gleam/list
import gleam/option
import gleam/string
import lustre
import lustre/attribute.{type Attribute}
import lustre/component
import lustre/effect.{type Effect}
import lustre/element.{type Element}
import lustre/element/html
import lustre/event
import reusables/input

// TODO:
// [ ] Improve UI
// [ ] Increase the list of selection and do a scroll
// [ ] Improve search
pub fn register(
  name: String,
  get_list: fn(String, fn(Result(List(#(String, String)), SearchError)) -> Msg) ->
    Effect(Msg),
) -> Result(Nil, lustre.Error) {
  let component =
    lustre.component(
      init,
      fn(model, msg) { update(model, get_list, msg) },
      view,
      [
        component.on_attribute_change("input_label", fn(label) {
          Ok(ParentChangedInputLabel(label))
        }),
      ],
    )

  lustre.register(component, "search-autocomplete-" <> name)
}

pub fn element(name: String, attributes: List(Attribute(msg))) -> Element(msg) {
  element.element("search-autocomplete-" <> name, attributes, [])
}

pub fn attribute_input_label(value: String) -> Attribute(msg) {
  attribute.attribute("input_label", value)
}

pub fn on_click(handler: fn(String) -> msg) -> Attribute(msg) {
  event.on("change", {
    decode.at(["detail"], decode.string) |> decode.map(handler)
  })
}

// Types ------------------------------------------------------------------------------------

pub type SearchError {
  NetworkError
  DecodeError
}

// Model ------------------------------------------------------------------------------------

pub type Model {
  Model(
    search: String,
    results: List(#(String, String)),
    input_label: String,
    error: option.Option(SearchError),
  )
}

pub fn init(_) -> #(Model, Effect(Msg)) {
  #(Model("", [], "", option.None), effect.none())
}

// Update ------------------------------------------------------------------------------------

pub type Msg {
  UserChangedSearch(String)
  ParentChangedInputLabel(String)
  ApiReturnedSearchResults(Result(List(#(String, String)), SearchError))
  UserClickedOnRow(#(String, String))
}

fn update(
  model: Model,
  get_list: fn(String, fn(Result(List(#(String, String)), SearchError)) -> Msg) ->
    Effect(Msg),
  msg: Msg,
) -> #(Model, Effect(Msg)) {
  io.println(string.inspect(msg))
  case msg {
    UserChangedSearch(search) -> update_search(model, search, get_list)
    ParentChangedInputLabel(input_label) -> #(
      Model(..model, input_label:),
      effect.none(),
    )
    ApiReturnedSearchResults(Ok(results)) -> #(
      Model(..model, results:, error: option.None),
      effect.none(),
    )
    ApiReturnedSearchResults(Error(err)) -> #(
      Model(..model, results: [], error: option.Some(err)),
      effect.none(),
    )
    UserClickedOnRow(#(row_id, row_value)) -> #(
      Model(..model, results: [], search: row_value),
      event.emit("change", json.string(row_id)),
    )
  }
}

fn update_search(
  model: Model,
  search: String,
  get_list: fn(String, fn(Result(List(#(String, String)), SearchError)) -> Msg) ->
    Effect(Msg),
) -> #(Model, Effect(Msg)) {
  case string.length(search) > 4 {
    True -> #(
      Model(..model, search:),
      get_list(search, ApiReturnedSearchResults),
    )
    False -> #(Model(..model, search:), effect.none())
  }
}

// View -------------------------------------------------------------------------------------
pub fn view(model: Model) -> Element(Msg) {
  html.div([], [
    input.input(
      model.search,
      "",
      is_valid: False,
      on_focus: fn(msg) { UserChangedSearch(msg) },
      on_blur: option.None,
      is: "search",
      name: model.input_label <> "-input",
      label: model.input_label,
    ),
    case model.error {
      option.Some(_) ->
        html.p([], [html.text("Search failed, please try again.")])
      option.None ->
        case list.length(model.results) {
          0 -> element.none()
          _ -> view_results(model.results)
        }
    },
  ])
}

fn view_results(results: List(#(String, String))) -> Element(Msg) {
  html.div([results_styles()], list.map(results, fn(row) { view_row(row) }))
}

fn view_row(row: #(String, String)) -> Element(Msg) {
  html.div(
    [
      event.on("click", { decode.success(UserClickedOnRow(row)) }),
      attribute.value(row.0),
    ],
    [
      html.text(row.1),
    ],
  )
}

fn results_styles() -> Attribute(msg) {
  attribute.styles([#("", "")])
}
