import gleam/http/response
import gleam/json
import lustre/effect.{type Effect}
import rsvp
import shared/user.{user_decoder}

pub type Msg {
  ApiReturnedUser(Result(user.User, rsvp.Error))
  ApiLogout(Result(response.Response(String), rsvp.Error))
}

pub type ApiCall {
  GetWhoami
}

pub fn get(msg: ApiCall) -> Effect(Msg) {
  case msg {
    GetWhoami -> get_user()
  }
}

fn get_user() -> Effect(Msg) {
  let url = "/api/auth/whoami"
  rsvp.get(url, rsvp.expect_json(user_decoder(), ApiReturnedUser))
}

pub fn logout() -> Effect(Msg) {
  let url = "/api/auth/logout"
  rsvp.delete(url, json.string(""), rsvp.expect_ok_response(ApiLogout))
}
