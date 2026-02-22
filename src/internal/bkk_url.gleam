import gleam/list

pub fn arrivals_and_departures_for_stop(
  stop_ids: List(String),
  api_key: String,
) -> String {
  let uri =
    "https://futar.bkk.hu/api/query/v1/ws/otp/api/where/arrivals-and-departures-for-stop?"
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
