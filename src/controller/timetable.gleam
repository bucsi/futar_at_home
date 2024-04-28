import gleam/http/request
import gleam/json
import gleam/list
import gleam/string
import gleam/string_builder

import birl
import gleam/hackney
import wisp

import internal/bkk_url
import model/response/arrivals_and_departures_for_stop.{
  type ArrivalsAndDeparturesForStop,
} as stop
import model/timetable
import view/root

pub fn handle(request, api_key) {
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

fn construct_timetables(stop: ArrivalsAndDeparturesForStop) {
  let server_time = birl.from_unix(stop.current_time / 1000)

  stop.data.entry.stop_times
  |> list.map(timetable.create_row(
    _,
    stop.data.references.trips,
    stop.data.references.routes,
    server_time,
  ))
}
