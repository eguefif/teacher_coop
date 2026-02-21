import wisp.{log_error}

pub type ServerError {
  AccountCreation(String)
}

pub fn log_server_error(error: ServerError) {
  case error {
    AccountCreation(error) ->
      log_error("Error while creating account: " <> error)
  }
}
