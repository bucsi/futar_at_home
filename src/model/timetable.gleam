import gleam/dict
import gleam/option.{None, Some}

import birl

import model/response/arrivals_and_departures_for_stop as stop

pub type Row {
  Row(
    departure: String,
    is_live: Bool,
    is_uncertain: Bool,
    line: String,
    headsign: String,
    color: String,
  )
}

pub fn create_row(
  bus: stop.StopTime,
  trips: dict.Dict(String, stop.Trip),
  routes: dict.Dict(String, stop.Route),
  server_time: birl.Time,
) {
  let trip_id = bus.trip_id

  let assert Ok(trip) =
    trips
    |> dict.get(trip_id)

  let assert Ok(route) =
    routes
    |> dict.get(trip.route_id)

  let #(departure, live) = case bus.predicted_departure_time {
    Some(time) -> {
      #(birl.from_unix(time), True)
    }
    None -> {
      let departure =
        birl.from_unix(option.unwrap(bus.departure_time, birl.monotonic_now()))
      #(departure, False)
    }
  }

  // TimetableRow(
  //   departure: departure,
  //   is_live: live,
  //   is_uncertain: option.unwrap(bus.uncertain, False),
  //   line: trip.route_id,
  //   headsign: bus.stop_headsign,
  //   route: route,
  // )

  Row(
    departure: birl.legible_difference(server_time, departure),
    is_live: live,
    is_uncertain: option.unwrap(bus.uncertain, False),
    line: route.short_name,
    headsign: bus.stop_headsign,
    color: route.color,
  )
}
