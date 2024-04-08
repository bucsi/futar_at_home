import gleam/io
import gleam/json
import gleam/list
import dot_env
import dot_env/env
import gleam/fetch
import gleam/http/request
import gleam/javascript/promise
import internal/bkk_url
import internal/responses/stop

pub fn main() {
  dot_env.load()
  let assert Ok(api_key) = env.get("FUTAR_API_KEY")
  let assert Ok(req) =
    request.to(bkk_url.arrivals_and_departures_for_stop("BKK_F03392", api_key))

  use resp <- promise.try_await(fetch.send(req))
  use resp <- promise.try_await(fetch.read_text_body(resp))

  let assert Ok(stop_data) = json.decode(resp.body, stop.get_decoder())

  let assert Ok(first_departure) =
    stop_data.data.entry.stop_times
    |> list.at(0)

  io.debug(first_departure.stop_headsign)

  promise.resolve(Ok(Nil))
}
