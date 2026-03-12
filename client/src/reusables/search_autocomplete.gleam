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
import gleam/http/request
import gleam/io
import gleam/list
import gleam/option
import gleam/string
import js/window as js
import lustre
import lustre/attribute.{type Attribute}
import lustre/component
import lustre/effect.{type Effect}
import lustre/element.{type Element}
import lustre/element/html
import reusables/input
import rsvp

import shared/school.{type School, school_decoder}

pub fn register() -> Result(Nil, lustre.Error) {
  let component =
    lustre.component(init, update, view, [
      component.on_attribute_change("input_label", fn(label) {
        Ok(ParentChangedInputLabel(label))
      }),
    ])

  lustre.register(component, "search-autocomplete")
}

pub fn element(attributes: List(Attribute(msg))) -> Element(msg) {
  element.element("search-autocomplete", attributes, [])
}

pub fn attribute_input_label(value: String) -> Attribute(msg) {
  attribute.attribute("input_label", value)
}

// Model ------------------------------------------------------------------------------------

pub type Model {
  Model(search: String, results: List(School), input_label: String)
}

pub fn init(_) -> #(Model, Effect(Msg)) {
  #(Model("", [], ""), effect.none())
}

// Update ------------------------------------------------------------------------------------

pub type Msg {
  UserChangedSearch(String)
  ParentChangedInputLabel(String)
  ApiReturnedSearchResults(Result(List(School), rsvp.Error))
}

fn update(model: Model, msg: Msg) -> #(Model, Effect(Msg)) {
  io.println(string.inspect(msg))
  case msg {
    UserChangedSearch(search) -> update_search(model, search)
    ParentChangedInputLabel(input_label) -> #(
      Model(..model, input_label:),
      effect.none(),
    )
    ApiReturnedSearchResults(Ok(results)) -> #(
      Model(..model, results:),
      effect.none(),
    )
    // TODO: Handle error
    ApiReturnedSearchResults(Error(_err)) -> #(model, effect.none())
  }
}

fn update_search(model: Model, search: String) -> #(Model, Effect(Msg)) {
  case string.length(search) > 4 {
    True -> #(Model(..model, search:), search_api(search))
    False -> #(Model(..model, search:), effect.none())
  }
}

fn search_api(search: String) -> Effect(Msg) {
  let base_url = js.base_url()
  let assert Ok(req) = request.to(base_url <> "/api/school/search")
  req
  |> request.set_query([#("search", search)])
  |> rsvp.send(rsvp.expect_json(
    decode.list(school_decoder()),
    ApiReturnedSearchResults,
  ))
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
    case list.length(model.results) {
      0 -> element.none()
      _ -> view_results(model.results)
    },
  ])
}

fn view_results(results: List(School)) -> Element(Msg) {
  html.div([results_styles()], list.map(results, fn(row) { view_row(row) }))
}

fn view_row(row: School) -> Element(Msg) {
  html.div([], [
    html.text(row.name <> " " <> row.city_name <> " " <> row.code_departement),
  ])
}

fn results_styles() -> Attribute(msg) {
  attribute.styles([#("", "")])
}
