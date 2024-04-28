import gleam/erlang/process
import gleam/hackney
import gleam/http/request
import gleam/json
import gleam/list
import gleam/string
import gleam/string_builder

import birl
import dot_env
import dot_env/env
import mist
import wisp.{type Request, type Response}

import internal/bkk_url
import internal/responses/stop
import internal/timetable_line
import internal/web
import view/root

pub fn main() {
  wisp.configure_logger()
  dot_env.load()
  let assert Ok(api_key) = env.get("FUTAR_API_KEY")
  let secret_key_base = api_key

  let assert Ok(_) =
    wisp.mist_handler(handle_request(_, api_key), secret_key_base)
    |> mist.new
    |> mist.port(8080)
    |> mist.start_http

  process.sleep_forever()
}

pub fn handle_request(req: Request, api_key: String) -> Response {
  use _ <- web.middleware(req)

  let assert Ok(req) =
    request.to(bkk_url.arrivals_and_departures_for_stop(
      ["BKK_F03392", "BKK_19824287"],
      api_key,
    ))

  let assert Ok(resp) = hackney.send(req)

  case json.decode(resp.body, stop.get_decoder()) {
    Ok(decoded) -> {
      decoded
      |> construct_timetables
      |> root.template
      |> wisp.html_response(200)
    }
    Error(e) -> {
      e
      |> string.inspect
      |> string_builder.from_string
      |> wisp.html_response(500)
    }
  }
}

fn construct_timetables(stop: stop.Response) {
  let server_time = birl.from_unix(stop.current_time / 1000)

  stop.data.entry.stop_times
  |> list.map(timetable_line.from_stop_time(
    _,
    stop.data.references.trips,
    stop.data.references.routes,
  ))
  |> list.map(timetable_line.to_html_ready(_, server_time))
}
