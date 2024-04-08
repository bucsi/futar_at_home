import gleam/dynamic
import gleam/option.{type Option}

pub type Response {
  Response(
    current_time: Int,
    version: Int,
    status: String,
    code: Int,
    text: String,
    data: Data,
  )
}

pub type Data {
  Data(
    limit_exceeded: Bool,
    entry: Entry,
    references: dynamic.Dynamic,
    class: String,
  )
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

pub type StopTime {
  StopTime(
    stop_id: String,
    stop_headsign: String,
    departure_time: Int,
    predicted_departure_time: Option(Int),
    stop_sequence: Int,
    trip_id: String,
    service_date: String,
    wheelchair_accessible: Bool,
    alert_ids: List(String),
  )
}

fn get_stop_time_decoder() -> dynamic.Decoder(StopTime) {
  dynamic.decode9(
    StopTime,
    dynamic.field("stopId", dynamic.string),
    dynamic.field("stopHeadsign", dynamic.string),
    dynamic.field("departureTime", dynamic.int),
    dynamic.optional_field("predictedDepartureTime", dynamic.int),
    dynamic.field("stopSequence", dynamic.int),
    dynamic.field("tripId", dynamic.string),
    dynamic.field("serviceDate", dynamic.string),
    dynamic.field("wheelchairAccessible", dynamic.bool),
    dynamic.field("alertIds", dynamic.list(dynamic.string)),
  )
}

fn get_entry_decoder() -> dynamic.Decoder(Entry) {
  dynamic.decode5(
    Entry,
    dynamic.field("stopId", dynamic.string),
    dynamic.field("routeIds", dynamic.list(dynamic.string)),
    dynamic.field("alertIds", dynamic.list(dynamic.string)),
    dynamic.field("nearbyStopIds", dynamic.list(dynamic.string)),
    dynamic.field("stopTimes", dynamic.list(get_stop_time_decoder())),
  )
}

fn get_data_decoder() -> dynamic.Decoder(Data) {
  dynamic.decode4(
    Data,
    dynamic.field("limitExceeded", dynamic.bool),
    dynamic.field("entry", get_entry_decoder()),
    dynamic.field("references", dynamic.dynamic),
    dynamic.field("class", dynamic.string),
  )
}

pub fn get_decoder() -> dynamic.Decoder(Response) {
  dynamic.decode6(
    Response,
    dynamic.field("currentTime", dynamic.int),
    dynamic.field("version", dynamic.int),
    dynamic.field("status", dynamic.string),
    dynamic.field("code", dynamic.int),
    dynamic.field("text", dynamic.string),
    dynamic.field("data", get_data_decoder()),
  )
}
