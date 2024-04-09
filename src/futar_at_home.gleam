import gleam/io
import gleam/json
import gleam/list
import gleam/result
import birl
import dot_env
import dot_env/env
import gleam/hackney
import gleam/http/request
import internal/bkk_url
import internal/timetable_line
import internal/responses/stop

pub fn main() {
  dot_env.load()
  use api_key <- result.try(env.get("FUTAR_API_KEY"))

  let assert Ok(req) =
    request.to(bkk_url.arrivals_and_departures_for_stop(
      ["BKK_F03392", "BKK_19824287"],
      api_key,
    ))

  let assert Ok(resp) = hackney.send(req)

  let decoded_response = json.decode(resp.body, stop.get_decoder())
  case decoded_response {
    Ok(decoded_response) -> handle_stop_data(decoded_response)
    Error(err) -> {
      io.debug(err)
      Nil
    }
  }

  Ok(Nil)
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
  |> list.each(io.println)
}
