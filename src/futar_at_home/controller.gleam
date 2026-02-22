import gleam/http/request
import gleam/json
import gleam/list

import birl
import gleam/hackney
import wisp

import futar_at_home/model
import futar_at_home/view

const arrivals_and_departures_for_stop_url = "https://futar.bkk.hu/api/query/v1/ws/otp/api/where/arrivals-and-departures-for-stop?onlyDepartures=true&minutesAfter=90&minutesBefore=0&limit=7&appVersion=1.1.abc&version=4&includeReferences=compact"

pub fn render_timetable_for_stops(stops, api_key) {
  let assert Ok(req) =
    stops
    |> arrivals_and_departures_for_stop(api_key)
    |> request.to

  let assert Ok(resp) = hackney.send(req)

  case json.parse(resp.body, model.arrivals_and_departures_for_stop_decoder()) {
    Ok(decoded) -> {
      decoded
      |> construct_timetables
      |> view.template
      |> wisp.html_response(200)
    }
    Error(e) ->
      view.error_page_for_decode_error(resp.body, e)
      |> wisp.html_response(500)
  }
}

fn arrivals_and_departures_for_stop(
  stop_ids: List(String),
  api_key: String,
) -> String {
  let uri =
    arrivals_and_departures_for_stop_url
    <> "&onlyDepartures=true"
    <> "&minutesAfter=90"
    <> "&minutesBefore=0"
    <> "&limit=7"
    <> "&appVersion=1.1.abc"
    <> "&version=4"
    <> "&includeReferences=compact"
    <> "&key="
    <> api_key

  stop_ids
  |> list.fold(uri, fn(uri, stop_id) { uri <> "&stopId=" <> stop_id })
}

fn construct_timetables(stop: model.ArrivalsAndDeparturesForStop) {
  let server_time = birl.from_unix(stop.current_time / 1000)

  stop.data.entry.stop_times
  |> list.map(model.timetable_row(
    _,
    stop.data.references.trips,
    stop.data.references.routes,
    server_time,
  ))
}
