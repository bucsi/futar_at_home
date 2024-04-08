import gleam/string_builder.{append, from_string, to_string}

pub fn arrivals_and_departures_for_stop(
  stop_id: String,
  api_key: String,
) -> String {
  from_string(
    "https://futar.bkk.hu/api/query/v1/ws/otp/api/where/arrivals-and-departures-for-stop?",
  )
  |> append("&stopId=" <> stop_id)
  |> append("&onlyDepartures=true")
  |> append("&limit=60")
  |> append("&minResult=5")
  |> append("&appVersion=1.1.abc")
  |> append("&version=4")
  |> append("&includeReferences=trips")
  |> append("&key=" <> api_key)
  |> to_string()
}
