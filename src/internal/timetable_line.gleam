import gleam/io
import gleam/dict
import gleam/option
import birl
import internal/responses/stop

pub type TimetableLine {
  TimetableLine(departure: birl.Time, line: String, headsign: String)
}

pub fn from_stop_time(bus: stop.StopTime, trips: dict.Dict(String, stop.Trip)) {
  let trip_id = bus.trip_id

  let assert Ok(route) =
    trips
    |> dict.get(trip_id)

  let departure =
    bus.predicted_departure_time
    |> option.unwrap(bus.departure_time)
    |> birl.from_unix

  TimetableLine(
    departure: departure,
    line: route.route_id,
    headsign: bus.stop_headsign,
  )
}

pub fn print(timetable: TimetableLine, server_time: birl.Time) {
  io.print(
    birl.legible_difference(server_time, timetable.departure)
    <> " "
    <> timetable.line
    <> " ▶ ",
  )
  io.println(timetable.headsign)
}
