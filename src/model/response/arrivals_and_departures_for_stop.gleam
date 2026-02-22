import gleam/dict.{type Dict}
import gleam/dynamic
import gleam/dynamic/decode
import gleam/option.{type Option}

pub type ArrivalsAndDeparturesForStop {
  ArrivalsAndDeparturesForStop(
    current_time: Int,
    version: Int,
    status: String,
    code: Int,
    text: String,
    data: Data,
  )
}

pub fn arrivals_and_departures_for_stop_decoder() -> decode.Decoder(
  ArrivalsAndDeparturesForStop,
) {
  use current_time <- decode.field("currentTime", decode.int)
  use version <- decode.field("version", decode.int)
  use status <- decode.field("status", decode.string)
  use code <- decode.field("code", decode.int)
  use text <- decode.field("text", decode.string)
  use data <- decode.field("data", data_decoder())
  decode.success(ArrivalsAndDeparturesForStop(
    current_time:,
    version:,
    status:,
    code:,
    text:,
    data:,
  ))
}

pub type Data {
  Data(
    limit_exceeded: Bool,
    entry: Entry,
    references: References,
    class: String,
  )
}

fn data_decoder() -> decode.Decoder(Data) {
  use limit_exceeded <- decode.field("limitExceeded", decode.bool)
  use entry <- decode.field("entry", entry_decoder())
  use references <- decode.field("references", references_decoder())
  use class <- decode.field("class", decode.string)
  decode.success(Data(limit_exceeded:, entry:, references:, class:))
}

pub type Entry {
  Entry(
    stop_id: String,
    route_ids: List(String),
    alert_ids: List(String),
    nearby_stop_ids: List(String),
    stop_times: List(StopTime),
  )
}

fn entry_decoder() -> decode.Decoder(Entry) {
  use stop_id <- decode.field("stopId", decode.string)
  use route_ids <- decode.field("routeIds", decode.list(decode.string))
  use alert_ids <- decode.field("alertIds", decode.list(decode.string))
  use nearby_stop_ids <- decode.field(
    "nearbyStopIds",
    decode.list(decode.string),
  )
  use stop_times <- decode.field("stopTimes", decode.list(stop_time_decoder()))
  decode.success(Entry(
    stop_id:,
    route_ids:,
    alert_ids:,
    nearby_stop_ids:,
    stop_times:,
  ))
}

pub type StopTime {
  StopTime(
    stop_id: String,
    stop_headsign: String,
    departure_time: Option(Int),
    predicted_departure_time: Option(Int),
    uncertain: Option(Bool),
    trip_id: String,
    wheelchair_accessible: Bool,
    alert_ids: List(String),
  )
}

fn stop_time_decoder() -> decode.Decoder(StopTime) {
  use stop_id <- decode.field("stopId", decode.string)
  use stop_headsign <- decode.field("stopHeadsign", decode.string)
  use departure_time <- decode.optional_field(
    "departureTime",
    option.None,
    decode.optional(decode.int),
  )
  use predicted_departure_time <- decode.optional_field(
    "predictedDepartureTime",
    option.None,
    decode.optional(decode.int),
  )
  use uncertain <- decode.optional_field(
    "uncertain",
    option.None,
    decode.optional(decode.bool),
  )
  use trip_id <- decode.field("tripId", decode.string)
  use wheelchair_accessible <- decode.field("wheelchairAccessible", decode.bool)
  use alert_ids <- decode.field("alertIds", decode.list(decode.string))
  decode.success(StopTime(
    stop_id:,
    stop_headsign:,
    departure_time:,
    predicted_departure_time:,
    uncertain:,
    trip_id:,
    wheelchair_accessible:,
    alert_ids:,
  ))
}

pub type References {
  References(
    agencies: Dict(String, dynamic.Dynamic),
    routes: Dict(String, Route),
    stops: Dict(String, dynamic.Dynamic),
    trips: Dict(String, Trip),
    alerts: Dict(String, dynamic.Dynamic),
  )
}

fn references_decoder() -> decode.Decoder(References) {
  use agencies <- decode.field(
    "agencies",
    decode.dict(decode.string, decode.dynamic),
  )
  use routes <- decode.field(
    "routes",
    decode.dict(decode.string, route_decoder()),
  )
  use stops <- decode.field("stops", decode.dict(decode.string, decode.dynamic))
  use trips <- decode.field("trips", decode.dict(decode.string, trip_decoder()))
  use alerts <- decode.field(
    "alerts",
    decode.dict(decode.string, decode.dynamic),
  )
  decode.success(References(agencies:, routes:, stops:, trips:, alerts:))
}

pub type Trip {
  Trip(
    id: String,
    route_id: String,
    shape_id: String,
    trip_headsign: String,
    service_id: String,
  )
}

fn trip_decoder() -> decode.Decoder(Trip) {
  use id <- decode.field("id", decode.string)
  use route_id <- decode.field("routeId", decode.string)
  use shape_id <- decode.field("shapeId", decode.string)
  use trip_headsign <- decode.field("tripHeadsign", decode.string)
  use service_id <- decode.field("serviceId", decode.string)
  decode.success(Trip(id:, route_id:, shape_id:, trip_headsign:, service_id:))
}

pub type Route {
  Route(
    id: String,
    short_name: String,
    kind: String,
    color: String,
    text_color: String,
  )
}

fn route_decoder() -> decode.Decoder(Route) {
  use id <- decode.field("id", decode.string)
  use short_name <- decode.field("shortName", decode.string)
  use kind <- decode.field("type", decode.string)
  use color <- decode.field("color", decode.string)
  use text_color <- decode.field("textColor", decode.string)
  decode.success(Route(id:, short_name:, kind:, color:, text_color:))
}
