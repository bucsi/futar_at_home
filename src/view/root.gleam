import gleam/list

import lustre/attribute.{attribute}
import lustre/element
import lustre/element/html.{
  body, div, h1, head, html, link, main, meta, span, table, tbody, td, th, thead,
  title, tr,
}

import internal/timetable_line.{type HtmlReadyTimetableLine}
import view/util

pub fn template(timetable lines: List(HtmlReadyTimetableLine)) {
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
        element.text(
          "Mátyásföld, Rendőrség | Mátyásföld, Repülőtér H",
        ),
      ]),
      main([], [
        table([], [
          thead([], [
            tr([], [
              th([], [element.text("Line")]),
              th([], [element.text("Destination")]),
              th([], [element.text("Departs")]),
              th([], [element.text("")]),
            ]),
          ]),
          tbody([], list.map(lines, render_row)),
        ]),
      ]),
      ..util.use_lucide()
    ]),
  ])
  |> element.to_string_builder
}

fn render_row(line: HtmlReadyTimetableLine) {
  tr([], [
    td([], [
      div(
        [
          attribute("class", "line-number"),
          attribute("style", "background-color: " <> line.color),
        ],
        [element.text(line.line)],
      ),
    ]),
    td([], [
      span([attribute("class", "destination-chevron")], [element.text("▶ ")]),
      span([], [element.text(line.headsign)]),
    ]),
    td([], [element.text(line.departure)]),
    td([], [get_status(line.is_live, line.is_uncertain)]),
  ])
}

fn get_status(live: Bool, uncertain: Bool) {
  case live, uncertain {
    _, True -> util.lucide("hourglass")
    True, _ -> util.lucide("radio")
    _, _ -> util.lucide("calendar-clock")
  }
}
