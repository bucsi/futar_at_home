import gleam/string
import gleam/json
import gleam/list
import gleam/option

import birdie
import gleeunit
import pprint
import simplifile

import futar_at_home/model
import futar_at_home/view

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
    json |> json.parse(model.arrivals_and_departures_for_stop_decoder())

  stop
  |> to_string
  |> birdie.snap("arrivals_and_departures_for_stop_decoding")
}

pub fn render_test() {
  get_all_combinations_for_timetable_row()
  |> view.template
  |> string.replace("<", "\n<")
  |> birdie.snap("rendering__timetable_rows")
}

fn get_all_combinations_for_timetable_row() {
  use status <- list.map([model.Live, model.Uncertain, model.Scheduled])
  model.TimetableRow(
    departure: "in 5 minutes",
    status: status,
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
