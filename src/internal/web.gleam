import gleam/list
import wisp
import lustre/element
import lustre/element/html.{
  body, div, h1, head, html, link, main, meta, span, table, tbody, td, th, thead,
  title, tr,
}
import lustre/attribute.{attribute}
import internal/timetable_line.{type HtmlReadyTimetableLine}

pub fn middleware(
  req: wisp.Request,
  handle_request: fn(wisp.Request) -> wisp.Response,
) -> wisp.Response {
  use <- wisp.log_request(req)
  use <- wisp.rescue_crashes
  use <- wisp.serve_static(req, under: "/static", from: static_directory())
  use req <- wisp.handle_head(req)

  handle_request(req)
}

fn static_directory() -> String {
  let assert Ok(priv_directory) = wisp.priv_directory("futar_at_home")
  priv_directory <> "/static"
}

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
    td([], [element.text(get_status(line.is_live, line.is_uncertain))]),
  ])
}

fn get_status(live: Bool, uncertain: Bool) -> String {
  case live, uncertain {
    _, True -> "delayed"
    True, _ -> "live"
    _, _ -> "planned"
  }
}
