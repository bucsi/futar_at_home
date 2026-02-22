import gleam/json
import gleam/list
import gleam/option

import gleeunit
import birdie
import pprint
import simplifile

import view/root
import model/timetable
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
  |> birdie.snap("arrivals_and_departures_for_stop_decoding")
}

pub fn render_test() {
  get_all_combinations_for_timetable_row()
  |> list.flatten
  |> root.template
  |> birdie.snap("rendering__timetable_rows")
}

fn get_all_combinations_for_timetable_row() {
  use bool1 <- list.map([True, False])
  use bool2 <- list.map([True, False])
  timetable.Row(
    departure: "in 5 minutes",
    is_live: bool1,
    is_uncertain: bool2,
    line: "123",
    headsign: "Deploy",
    color: "#b00b50",
  )
}

fn to_string(any: a) -> String {
  any
  |> pprint.with_config(pprint.Config(
    pprint.Unstyled,
    pprint.BitArraysAsString,
    pprint.Labels,
  ))
}
