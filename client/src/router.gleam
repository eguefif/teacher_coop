import gleam/uri

pub type Route {
  Signup
  Login
  Search
}

pub fn from_uri(uri: uri.Uri) -> Route {
  uri.path_segments(uri.path)
  |> fn(path) {
    case path {
      ["search"] -> Search
      ["login"] -> Login
      ["signup"] -> Signup
      _ -> Search
    }
  }
}

pub fn is_protected_route(route: Route) -> Bool {
  case route {
    Signup | Login | Search -> False
  }
}
