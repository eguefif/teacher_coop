import gleam/dynamic/decode
import gleam/http/request
import js/window as js
import lustre/effect.{type Effect}
import reusables/search_autocomplete.{type SearchError, DecodeError, NetworkError}
import rsvp
import shared/school.{school_tupple_decoder}

pub fn search_schools(
  search: String,
  msg: fn(Result(List(#(String, String)), SearchError)) -> msg,
) -> Effect(msg) {
  let base_url = js.base_url()
  let assert Ok(req) = request.to(base_url <> "/api/school/search")
  req
  |> request.set_query([#("search", search)])
  |> rsvp.send(rsvp.expect_json(decode.list(school_tupple_decoder()), fn(result) {
    case result {
      Ok(list) -> msg(Ok(list))
      Error(rsvp.JsonError(_)) -> msg(Error(DecodeError))
      Error(_) -> msg(Error(NetworkError))
    }
  }))
}
