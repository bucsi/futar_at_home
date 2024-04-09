import gleam/io
import gleam/json
import gleam/list
import gleam/dict
import gleam/option
import gleam/result
import birl
import dot_env
import dot_env/env
import gleam/fetch
import gleam/http/request
import gleam/javascript/promise
import internal/bkk_url
import internal/timetable_line
import internal/responses/stop

pub fn main() {
  dot_env.load()
  use api_key <- result.try(env.get("FUTAR_API_KEY"))
  {
    let assert Ok(req) =
      request.to(bkk_url.arrivals_and_departures_for_stop("BKK_F03392", api_key))

    use resp <- promise.try_await(fetch.send(req))
    use resp <- promise.try_await(fetch.read_text_body(resp))

    let assert Ok(stop) = json.decode(resp.body, stop.get_decoder())
    let server_time = birl.from_unix(stop.current_time / 1000)

    stop.data.entry.stop_times
    |> list.map(timetable_line.from_stop_time(_, stop.data.references.trips))
    |> list.map(timetable_line.print(_, server_time))

    promise.resolve(Ok(Nil))
  }
  Ok(Nil)
}
