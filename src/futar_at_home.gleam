import gleam/io
import gleam/json
import gleam/list
import gleam/result
import gleam/string
import gleam/hackney
import gleam/string_builder
import gleam/http/request
import gleam/erlang/process
import birl
import mist
import wisp.{type Request, type Response}
import dot_env
import dot_env/env
import internal/web
import internal/bkk_url
import internal/timetable_line
import internal/responses/stop

pub fn main() {
  wisp.configure_logger()
  dot_env.load()
  let assert Ok(api_key) = env.get("FUTAR_API_KEY")
  let secret_key_base = api_key

  let assert Ok(_) =
    wisp.mist_handler(handle_request(_, api_key), secret_key_base)
    |> mist.new
    |> mist.port(8000)
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

  let decoded_response = json.decode(resp.body, stop.get_decoder())
  let response = case decoded_response {
    Ok(decoded_response) -> handle_stop_data(decoded_response)
    Error(err) -> {
      string.inspect(err)
    }
  }

  wisp.html_response(string_builder.from_string(response), 200)
}

fn handle_stop_data(stop: stop.Response) {
  let server_time = birl.from_unix(stop.current_time / 1000)

  stop.data.entry.stop_times
  |> list.map(timetable_line.from_stop_time(
    _,
    stop.data.references.trips,
    stop.data.references.routes,
  ))
  |> list.map(timetable_line.to_string(_, server_time))
  |> string.join("<br>")
}
