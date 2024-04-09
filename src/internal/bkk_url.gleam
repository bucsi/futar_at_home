import gleam/list
import gleam/string_builder.{append, from_string, to_string}
import gleam/io

pub fn arrivals_and_departures_for_stop(
  stop_ids: List(String),
  api_key: String,
) -> String {
  let uri =
    from_string(
      "https://futar.bkk.hu/api/query/v1/ws/otp/api/where/arrivals-and-departures-for-stop?",
    )
    |> append("&onlyDepartures=true")
    |> append("&minutesAfter=90")
    |> append("&minutesBefore=0")
    |> append("&limit=7")
    |> append("&appVersion=1.1.abc")
    |> append("&version=4")
    |> append("&includeReferences=compact")
    |> append("&key=" <> api_key)

  stop_ids
  |> list.fold(uri, fn(uri, stop_id) { append(uri, "&stopId=" <> stop_id) })
  |> to_string()
}
