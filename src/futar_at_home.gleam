import gleam/erlang/process

import dot_env
import dot_env/env
import mist
import wisp

import router

pub fn main() {
  wisp.configure_logger()
  dot_env.load()
  let assert Ok(api_key) = env.get("FUTAR_API_KEY")
  let secret_key_base = api_key

  let assert Ok(_) =
    wisp.mist_handler(router.handle_request(_, api_key), secret_key_base)
    |> mist.new
    |> mist.port(8080)
    |> mist.start_http

  process.sleep_forever()
}
