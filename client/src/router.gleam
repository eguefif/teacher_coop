import gleam/uri

pub type Route {
  Signup
  Login
  Search
  Workspace
  Admin
}

pub fn from_uri(uri: uri.Uri) -> Route {
  uri.path_segments(uri.path)
  |> fn(path) {
    case path {
      ["search"] -> Search
      ["login"] -> Login
      ["signup"] -> Signup
      ["workspace"] -> Workspace
      ["admin"] -> Admin
      _ -> Search
    }
  }
}

pub fn is_protected_route(route: Route) -> Bool {
  case route {
    Signup | Login | Search -> False
    _ -> True
  }
}

pub fn is_admin_route(route: Route) -> Bool {
  case route {
    Admin -> True
    _ -> False
  }
}
