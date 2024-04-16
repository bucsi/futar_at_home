import gleam/dict
import gleam/option
import gleam/string
import gleam/string_builder
import birl
import internal/responses/stop

pub type TimetableLine {
  TimetableLine(
    departure: birl.Time,
    line: String,
    headsign: String,
    route: stop.Route,
  )
}

pub type HtmlReadyTimetableLine {
  HtmlReadyTimetableLine(
    departure: String,
    line: String,
    headsign: String,
    color: String,
  )
}

pub fn from_stop_time(
  bus: stop.StopTime,
  trips: dict.Dict(String, stop.Trip),
  routes: dict.Dict(String, stop.Route),
) {
  let trip_id = bus.trip_id

  let assert Ok(trip) =
    trips
    |> dict.get(trip_id)

  let assert Ok(route) =
    routes
    |> dict.get(trip.route_id)

  let departure =
    bus.predicted_departure_time
    |> option.unwrap(bus.departure_time)
    |> birl.from_unix

  TimetableLine(
    departure: departure,
    line: trip.route_id,
    headsign: bus.stop_headsign,
    route: route,
  )
}

pub fn to_html_ready(timetable: TimetableLine, server_time: birl.Time) {
  HtmlReadyTimetableLine(
    departure: birl.legible_difference(server_time, timetable.departure),
    line: timetable.route.short_name,
    headsign: timetable.headsign,
    color: timetable.route.color,
  )
}

pub fn to_string(timetable: TimetableLine, server_time: birl.Time) {
  string_builder.new()
  |> string_builder.append(string.pad_left(
    birl.legible_difference(server_time, timetable.departure),
    13,
    " ",
  ))
  |> string_builder.append(" ")
  |> string_builder.append(string.pad_left(timetable.route.short_name, 4, ""))
  |> string_builder.append(" ▶ ")
  |> string_builder.append(string.pad_left(timetable.headsign, 40, " "))
  |> string_builder.append(" ")
  |> string_builder.append(string.pad_left(timetable.route.kind, 1, ""))
  |> string_builder.append(" ")
  |> string_builder.append(timetable.route.color)
  |> string_builder.append(" ")
  |> string_builder.append(timetable.route.style.vehicle_icon.name)
  |> string_builder.to_string()
}
