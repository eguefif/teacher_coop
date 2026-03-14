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
import reusables/input
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
  NoSelectionError
}

// Model ------------------------------------------------------------------------------------

pub type Model {
  Model(
    search: String,
    results: List(#(String, String)),
    input_label: String,
    dropdown_visible: Bool,
    // This index is used for keyboard navigation
    nav_row_idx: option.Option(Int),
    error: option.Option(SearchError),
    school_selected: option.Option(#(String, String)),
  )
}

pub fn init(_) -> #(Model, Effect(Msg)) {
  #(
    Model("", [], "", False, option.None, option.None, option.None),
    effect.none(),
  )
}

// Update ------------------------------------------------------------------------------------

pub type Msg {
  UserChangedSearch(String)
  ParentChangedInputLabel(String)
  ApiReturnedSearchResults(Result(List(#(String, String)), SearchError))
  UserClickedOnRow(#(String, String))
  UserClickedOutside
  UserPressedKey(String)
  UserDidNothing
  UserSelectedRowWithKeyboard(Int)
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
    UserClickedOnRow(selection) -> #(
      Model(
        ..model,
        results: [],
        school_selected: option.Some(selection),
        search: selection.1,
      ),
      event.emit("change", json.string(selection.0)),
    )
    UserClickedOutside -> #(
      Model(..model, dropdown_visible: False),
      effect.none(),
    )
    UserDidNothing -> #(model, effect.none())
    UserPressedKey(key) -> update_key_pressed(key, model)
    UserSelectedRowWithKeyboard(index) -> {
      let selection = get_result_from_index(model.results, 0, index)
      #(
        Model(
          ..model,
          school_selected: option.Some(selection),
          results: [],
          search: selection.1,
        ),
        event.emit("change", json.string(selection.0)),
      )
    }
  }
}

fn get_result_from_index(
  results: List(#(String, String)),
  idx: Int,
  lookup: Int,
) -> #(String, String) {
  case idx == lookup, results {
    True, [first, ..] -> first
    False, [_, ..rest] -> get_result_from_index(rest, idx + 1, lookup)
    _, [] -> panic
  }
}

fn update_key_pressed(key: String, model: Model) -> #(Model, Effect(Msg)) {
  let results_length = list.length(model.results)
  let nav_row_idx = case model.nav_row_idx {
    option.Some(row_index) -> {
      case key {
        "ArrowUp" if row_index - 1 < 0 -> option.Some(results_length - 1)
        "ArrowUp" -> option.Some(row_index - 1)
        "ArrowDown" if row_index + 1 >= results_length -> option.Some(0)
        "ArrowDown" -> option.Some(row_index + 1)
        _ -> option.None
      }
    }
    option.None if key == "ArrowUp" || key == "ArrowDown" -> option.Some(0)
    _ -> option.None
  }
  // Check if enter is pressed
  case key, model.nav_row_idx {
    "Enter", option.Some(idx) -> #(
      Model(..model, dropdown_visible: False),
      effect.from(fn(dispatch) { dispatch(UserSelectedRowWithKeyboard(idx)) }),
    )
    _, _ -> #(Model(..model, nav_row_idx:), effect.none())
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
      Model(..model, search:, school_selected: option.None),
      get_list(search, ApiReturnedSearchResults),
    )
    False -> #(Model(..model, search:), effect.none())
  }
}

// View -------------------------------------------------------------------------------------

pub fn view(model: Model) -> Element(Msg) {
  html.div([event.on_keydown(UserPressedKey)], [
    component_style(),
    view_input(model),
    case model.error {
      option.Some(_) ->
        html.p([], [html.text("Search failed, please try again.")])
      option.None ->
        case list.length(model.results) {
          0 -> element.none()
          _ if model.dropdown_visible == True ->
            view_results(model.results, model.nav_row_idx)
          _ -> element.none()
        }
    },
  ])
}

fn view_input(model: Model) -> Element(Msg) {
  input.input(
    model.search,
    "",
    is_valid: option.is_some(model.school_selected),
    on_focus: UserChangedSearch,
    on_blur: option.None,
    is: "search",
    name: model.input_label <> "-input",
    label: model.input_label,
  )
}

fn view_results(
  results: List(#(String, String)),
  nav_idx: option.Option(Int),
) -> Element(Msg) {
  html.div([attribute.style("position", "relative")], [
    overlay(UserClickedOutside, UserDidNothing),
    html.div(
      [attribute.class("search-results")],
      list.index_map(results, fn(row, index) { view_row(row, index, nav_idx) }),
    ),
  ])
}

fn view_row(
  row: #(String, String),
  index: Int,
  nav_idx: option.Option(Int),
) -> Element(Msg) {
  html.div(
    [
      case nav_idx {
        option.Some(nav_idx) if index == nav_idx ->
          attribute.style("background-color", "var(--color-primary-dark)")
        _ -> attribute.none()
      },
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
