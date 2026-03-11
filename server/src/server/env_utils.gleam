import envoy

pub fn is_dev() -> Bool {
  case envoy.get("ENV") {
    Ok("DEV") -> True
    _ -> False
  }
}

/// Returns if we can skip password
///
/// This can only be used in DEV env
pub fn skip_password() -> Bool {
  let env = is_dev()
  case envoy.get("SKIP_PASSWORD") {
    Ok("TRUE") if env -> True
    _ -> False
  }
}
