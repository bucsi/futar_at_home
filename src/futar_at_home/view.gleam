import gleam/json
import gleam/list
import gleam/string

import lustre/attribute.{attribute}
import lustre/element
import lustre/element/html.{
  body, code, div, h1, head, html, link, main, meta, p, pre, span, table, tbody,
  td, text, th, thead, title, tr,
}

import futar_at_home/model

pub fn template(timetable lines: List(model.TimetableRow)) {
  html([], [
    head([], [
      meta([attribute("charset", "utf-8")]),
      meta([
        attribute("name", "viewport"),
        attribute("content", "width=device-width, initial-scale=1"),
      ]),
      link([
        attribute("rel", "stylesheet"),
        attribute("href", "/static/style.css"),
      ]),
      link([attribute("rel", "icon"), attribute("href", "/static/favicon.ico")]),
      title([], "Futár@home"),
    ]),
    body([], [
      h1([], [
        text("Jókai Mór utca, Rendőrség | Mátyásföld, Repülőtér H"),
      ]),
      main([], [
        table([], [
          thead([], [
            tr([], [
              th([], [text("Line")]),
              th([], [text("Destination")]),
              th([], [text("Departs")]),
              th([], [text("")]),
            ]),
          ]),
          tbody([], list.map(lines, render_row)),
        ]),
      ]),
      ..use_lucide()
    ]),
  ])
  |> element.to_string
}

pub fn error_page_for_decode_error(
  json: String,
  error: json.DecodeError,
) -> String {
  main([], [
    h1([], [text("Internal Server Error")]),
    p([], [
      text("Could not decode JSON response from API: "),
      code([], [
        pre([], [text(json)]),
      ]),
    ]),
    p([], [
      text("Error: "),
      code([], [text(string.inspect(error))]),
    ]),
  ])
  |> element.to_string
}

fn render_row(row: model.TimetableRow) {
  tr([], [
    td([], [
      div(
        [
          attribute("class", "line-number"),
          attribute("style", "background-color: " <> row.color),
        ],
        [text(row.line)],
      ),
    ]),
    td([], [
      span([attribute("class", "destination-chevron")], [text("▶ ")]),
      span([], [text(row.headsign)]),
    ]),
    td([], [text(row.departure)]),
    td([], [get_status(row.status)]),
  ])
}

fn get_status(status: model.DepartureStatus) {
  case status {
    model.Live -> lucide("radio")
    model.Uncertain -> lucide("hourglass")
    model.Scheduled -> lucide("calendar-clock")
  }
}

fn use_lucide() {
  [
    html.script([attribute.src("https://unpkg.com/lucide@latest")], ""),
    html.script([], "lucide.createIcons()"),
  ]
}

fn lucide(icon name: String) {
  html.i([attribute.attribute("data-lucide", name)], [])
}
