import birdie
import gleam/json
import gleam/option
import gleam/result
import gleeunit
import pprint
import simplifile

import model/response/arrivals_and_departures_for_stop as stop

pub type TestError {
  FileError(simplifile.FileError)
  JsonError(json.DecodeError)
}

pub fn main() {
  gleeunit.main()
}

pub type Alma {
  Alma(harom: option.Option(Int))
}

pub fn decode_test() {
  let assert Ok(json) = simplifile.read("test/exampleData.json")
  let assert Ok(stop) =
    json |> json.parse(stop.arrivals_and_departures_for_stop_decoder())

  stop
  |> to_string
  |> birdie.snap("arrivals_and_departures_for_stop_decoding.snap")
}

fn to_string(any: a) -> String {
  any
  |> pprint.with_config(pprint.Config(
    pprint.Unstyled,
    pprint.BitArraysAsString,
    pprint.Labels,
  ))
}
