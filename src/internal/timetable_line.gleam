import gleam/dict
import gleam/option
import gleam/string_builder
import birl
import internal/responses/stop
import internal/util/pad.{PadLeft, PadRight, pad}

pub type TimetableLine {
  TimetableLine(
    departure: birl.Time,
    line: String,
    headsign: String,
    route: stop.Route,
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

pub fn to_string(timetable: TimetableLine, server_time: birl.Time) {
  string_builder.new()
  |> string_builder.append(pad(
    birl.legible_difference(server_time, timetable.departure),
    PadLeft,
    13,
  ))
  |> string_builder.append(" ")
  |> string_builder.append(pad(timetable.route.short_name, PadLeft, 4))
  |> string_builder.append(" ▶ ")
  |> string_builder.append(pad(timetable.headsign, PadRight, 40))
  |> string_builder.append(" ")
  |> string_builder.append(pad(timetable.route.kind, PadRight, 16))
  |> string_builder.append(" ")
  |> string_builder.append(timetable.route.color)
  |> string_builder.append(" ")
  |> string_builder.append(timetable.route.style.vehicle_icon.name)
  |> string_builder.to_string()
}
