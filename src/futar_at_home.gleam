import gleam/result.{try}
import gleam/hackney
import gleam/json
import gleam/http/request
import gleam/io
import gleam/dynamic
import gleam/string
import internal/env
import internal/bkk_url

pub fn main() {
  let api_key = env.load()
  io.debug(bkk_url.arrivals_and_departures_for_stop("BKK_F03392", api_key))
  let assert Ok(request) =
    request.to(bkk_url.arrivals_and_departures_for_stop("BKK_F03392", api_key))

  use response <- try(hackney.send(request))

  try(
    json.decode(response.body, dynamic.dict(dynamic.string, dynamic.dynamic)),
    fn(v) {
      io.debug(v)
      Ok(Nil)
    },
  )

  Ok(Nil)
}
