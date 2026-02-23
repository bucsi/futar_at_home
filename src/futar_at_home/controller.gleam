import gleam/http/request
import gleam/http/response.{type Response}
import gleam/json
import gleam/list

import birl
import gleam/hackney
import wisp

import futar_at_home/model
import futar_at_home/view

const arrivals_and_departures_for_stop_url = "https://futar.bkk.hu/api/query/v1/ws/otp/api/where/arrivals-and-departures-for-stop?onlyDepartures=true&minutesAfter=90&minutesBefore=0&limit=7&appVersion=1.1.abc&version=4&includeReferences=compact"

const jokai_mor_utca_rendorseg = model.Stop(
  id: "BKK_F03392",
  name: "Jókai Mór utca, Rendőrség",
)

const matyasfold_repuloter_h = model.Stop(
  id: "BKK_19824287",
  name: "Mátyásföld, Repülőtér H",
)

const godollo_szabadsag_ter_h = model.Stop(
  id: "BKK_19868322",
  name: "Gödöllő, Szabadság tér H",
)

pub fn matyasfold_rendorseg(api_key: String) -> Response(wisp.Body) {
  [jokai_mor_utca_rendorseg, matyasfold_repuloter_h]
  |> render_timetable_for_stops(api_key)
}

pub fn godollo_szabadsag_ter(api_key: String) -> Response(wisp.Body) {
  [godollo_szabadsag_ter_h]
  |> render_timetable_for_stops(api_key)
}

fn render_timetable_for_stops(
  stops: List(model.Stop),
  api_key: String,
) -> Response(wisp.Body) {
  let assert Ok(req) =
    stops
    |> arrivals_and_departures_for_stop(api_key)
    |> request.to

  let assert Ok(resp) = hackney.send(req)

  case json.parse(resp.body, model.arrivals_and_departures_for_stop_decoder()) {
    Ok(decoded) -> {
      decoded
      |> construct_timetables
      |> view.template(stops)
      |> wisp.html_response(200)
    }
    Error(e) ->
      view.error_page_for_decode_error(resp.body, e)
      |> wisp.html_response(500)
  }
}

fn arrivals_and_departures_for_stop(
  stop_ids: List(model.Stop),
  api_key: String,
) -> String {
  let uri =
    arrivals_and_departures_for_stop_url
    <> "&onlyDepartures=true"
    <> "&minutesAfter=190"
    <> "&minutesBefore=0"
    <> "&limit=17"
    <> "&appVersion=1.1.abc"
    <> "&version=4"
    <> "&includeReferences=compact"
    <> "&key="
    <> api_key

  stop_ids
  |> list.fold(uri, fn(uri, stop) { uri <> "&stopId=" <> stop.id })
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
