import gleam/erlang/process
import gleam/http/request.{type Request}
import gleam/http/response.{type Response}

import dot_env
import dot_env/env
import mist
import wisp
import wisp/wisp_mist

import controller/timetable
import internal/web

fn handle_request(
  req: Request(wisp.Connection),
  api_key: String,
) -> Response(wisp.Body) {
  use req <- web.middleware(req)

  case wisp.path_segments(req) {
    [] -> timetable.handle(req, api_key)
    _ -> wisp.not_found()
  }
}

pub fn main() -> Nil {
  wisp.configure_logger()
  dot_env.load_default()
  let assert Ok(api_key) = env.get_string("FUTAR_API_KEY")
  let secret_key_base = api_key

  let assert Ok(_) =
    handle_request(_, api_key)
    |> wisp_mist.handler(secret_key_base)
    |> mist.new
    |> mist.port(8000)
    |> mist.start

  process.sleep_forever()
}
