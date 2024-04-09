import gleam/dynamic
import gleam/option.{type Option}
import gleam/dict.{type Dict}

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

pub type Data {
  Data(
    limit_exceeded: Bool,
    entry: Entry,
    references: References,
    class: String,
  )
}

fn get_data_decoder() -> dynamic.Decoder(Data) {
  dynamic.decode4(
    Data,
    dynamic.field("limitExceeded", dynamic.bool),
    dynamic.field("entry", get_entry_decoder()),
    dynamic.field("references", get_references_decoder()),
    dynamic.field("class", dynamic.string),
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

pub type References {
  References(
    agencies: Dict(String, dynamic.Dynamic),
    routes: Dict(String, Route),
    stops: Dict(String, dynamic.Dynamic),
    trips: Dict(String, Trip),
    alerts: Dict(String, dynamic.Dynamic),
  )
}

pub fn get_references_decoder() -> dynamic.Decoder(References) {
  dynamic.decode5(
    References,
    dynamic.field("agencies", dynamic.dict(dynamic.string, dynamic.dynamic)),
    dynamic.field("routes", dynamic.dict(dynamic.string, get_route_decoder())),
    dynamic.field("stops", dynamic.dict(dynamic.string, dynamic.dynamic)),
    dynamic.field("trips", dynamic.dict(dynamic.string, get_trip_decoder())),
    dynamic.field("alerts", dynamic.dict(dynamic.string, dynamic.dynamic)),
  )
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

pub fn get_trip_decoder() -> dynamic.Decoder(Trip) {
  dynamic.decode5(
    Trip,
    dynamic.field("id", dynamic.string),
    dynamic.field("routeId", dynamic.string),
    dynamic.field("shapeId", dynamic.string),
    dynamic.field("tripHeadsign", dynamic.string),
    dynamic.field("serviceId", dynamic.string),
  )
}

pub type Route {
  Route(
    id: String,
    short_name: String,
    kind: String,
    color: String,
    text_color: String,
    style: Style,
  )
}

fn get_route_decoder() -> dynamic.Decoder(Route) {
  dynamic.decode6(
    Route,
    dynamic.field("id", dynamic.string),
    dynamic.field("shortName", dynamic.string),
    dynamic.field("type", dynamic.string),
    dynamic.field("color", dynamic.string),
    dynamic.field("textColor", dynamic.string),
    dynamic.field("style", get_style_decoder()),
  )
}

pub type Style {
  Style(color: String, icon: Icon, vehicle_icon: VehicleIcon)
}

fn get_style_decoder() -> dynamic.Decoder(Style) {
  dynamic.decode3(
    Style,
    dynamic.field("color", dynamic.string),
    dynamic.field("icon", get_icon_decoder()),
    dynamic.field("vehicleIcon", get_vehicle_icon_decoder()),
  )
}

pub type Icon {
  Icon(kind: String, text_color: String)
}

fn get_icon_decoder() -> dynamic.Decoder(Icon) {
  dynamic.decode2(
    Icon,
    dynamic.field("type", dynamic.string),
    dynamic.field("textColor", dynamic.string),
  )
}

pub type VehicleIcon {
  VehicleIcon(
    name: String,
    color: Option(String),
    secondary_color: Option(String),
  )
}

fn get_vehicle_icon_decoder() -> dynamic.Decoder(VehicleIcon) {
  dynamic.decode3(
    VehicleIcon,
    dynamic.field("name", dynamic.string),
    dynamic.optional_field("color", dynamic.string),
    dynamic.optional_field("secondaryColor", dynamic.string),
  )
}
