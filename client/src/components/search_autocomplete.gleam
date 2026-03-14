//// Display a search input with autocomplete
////
//// When a user type, after a three letters, search kick-off
//// Results are displayed in a dropdown poper and are selectable.
//// The the user need to choose a result to complete the input
////

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
import reusables/overlay.{overlay}

// TODO:
// [ ] We want to add more result
// [ ] Implement a scroll
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
    dropdown_visible: Bool,
    error: option.Option(SearchError),
  )
}

pub fn init(_) -> #(Model, Effect(Msg)) {
  #(Model("", [], "", False, option.None), effect.none())
}

// Update ------------------------------------------------------------------------------------

pub type Msg {
  UserChangedSearch(String)
  ParentChangedInputLabel(String)
  ApiReturnedSearchResults(Result(List(#(String, String)), SearchError))
  UserClickedOnRow(#(String, String))
  UserClickedOutside
  UserDidNothing
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
      Model(..model, results:, dropdown_visible: True, error: option.None),
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
    UserClickedOutside -> #(
      Model(..model, dropdown_visible: False),
      effect.none(),
    )
    UserDidNothing -> #(model, effect.none())
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
    component_style(),
    view_input(model),
    case model.error {
      option.Some(_) ->
        html.p([], [html.text("Search failed, please try again.")])
      option.None ->
        case list.length(model.results) {
          0 -> element.none()
          _ if model.dropdown_visible == True -> view_results(model.results)
          _ -> element.none()
        }
    },
  ])
}

fn view_input(model: Model) -> Element(Msg) {
  let name = model.input_label <> "-input"
  html.div([attribute.class("search-input-container")], [
    html.label([attribute.for(name)], [html.text(model.input_label)]),
    html.input([
      attribute.type_("search"),
      attribute.id(name),
      attribute.value(model.search),
      event.on_input(UserChangedSearch),
    ]),
  ])
}

fn view_results(results: List(#(String, String))) -> Element(Msg) {
  html.div([attribute.style("position", "relative")], [
    overlay(UserClickedOutside, UserDidNothing),
    html.div(
      [attribute.class("search-results")],
      list.map(results, fn(row) { view_row(row) }),
    ),
  ])
}

fn view_row(row: #(String, String)) -> Element(Msg) {
  html.div(
    [
      attribute.class("search-row"),
      event.on("click", { decode.success(UserClickedOnRow(row)) }),
      attribute.value(row.0),
    ],
    [html.text(row.1)],
  )
}

fn component_style() -> Element(Msg) {
  html.style(
    [],
    "
    .search-input-container {
      display: flex;
      width: var(--input-width);
      flex-direction: column;
      gap: 4px;
      padding-bottom: 32px;
    }
    .search-results {
      position: absolute;
      left: 0;
      top: -34px;
      display: flex;
      z-index: 15;
      flex-direction: column;
      background-color: var(--color-primary-light);
      margin: 0px 0px 12px 0px;
      width: var(--input-width);
      border: 0px solid var(--color-primary);
      border-color: var(--color-primary);
      border-radius: 0px 0px 16px 16px;
      box-shadow: 0 0 0 3px var(--color-primary-light);
      animation: dropdown-in 550ms ease-in-out;
      overflow: hidden;
    }
    .search-row {
      z-index: 15;
      font-size: 14px;
      padding: 12px;
    }
    .search-row:hover {
      cursor: pointer;
      background-color: var(--color-primary-dark);
    }
    .search-row:last-of-type {
      padding-top: 14px;
      border-radius: 0px 0px 16px 16px;
    }
    .search-row:first-of-type {
      padding-bottom: 14px;
    }
    @keyframes dropdown-in {
      from {
        opacity: 0;
        max-height: 50px;
      }
      to {
        opacity: 1;
        max-height: 900px;
      }
    }
    ",
  )
}
