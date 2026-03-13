import components/search_autocomplete.{
  type SearchError, DecodeError, NetworkError,
}
import gleam/dynamic/decode
import gleam/http/request
import gleam/list
import js/window as js
import lustre/effect.{type Effect}
import rsvp
import shared/school.{school_decoder}

pub fn search_schools(
  search: String,
  msg: fn(Result(List(#(String, String)), SearchError)) -> msg,
) -> Effect(msg) {
  let base_url = js.base_url()
  let assert Ok(req) = request.to(base_url <> "/api/school/search")
  req
  |> request.set_query([#("search", search)])
  |> rsvp.send(
    rsvp.expect_json(decode.list(school_decoder()), fn(result) {
      case result {
        Ok(schools_list) ->
          msg(Ok(
            schools_list
            |> list.map(fn(school) {
              #(
                school.id,
                school.name
                  <> " ("
                  <> school.city_name
                  <> " - "
                  <> school.code_departement
                  <> ")",
              )
            }),
          ))
        Error(rsvp.JsonError(_)) -> msg(Error(DecodeError))
        Error(_) -> msg(Error(NetworkError))
      }
    }),
  )
}
