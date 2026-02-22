import gleam/list

import lustre/attribute.{attribute}
import lustre/element
import lustre/element/html.{
  body, div, h1, head, html, link, main, meta, span, table, tbody, td, th, thead,
  title, tr,
}

import model/timetable
import view/util

pub fn template(timetable lines: List(timetable.Row)) {
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
        element.text("Jókai Mór utca, Rendőrség | Mátyásföld, Repülőtér H"),
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
  |> element.to_string
}

fn render_row(row: timetable.Row) {
  tr([], [
    td([], [
      div(
        [
          attribute("class", "line-number"),
          attribute("style", "background-color: " <> row.color),
        ],
        [element.text(row.line)],
      ),
    ]),
    td([], [
      span([attribute("class", "destination-chevron")], [element.text("▶ ")]),
      span([], [element.text(row.headsign)]),
    ]),
    td([], [element.text(row.departure)]),
    td([], [get_status(row.is_live, row.is_uncertain)]),
  ])
}

fn get_status(live: Bool, uncertain: Bool) {
  case live, uncertain {
    _, True -> util.lucide("hourglass")
    True, _ -> util.lucide("radio")
    _, _ -> util.lucide("calendar-clock")
  }
}
