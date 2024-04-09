import gleam/list
import wisp
import lustre/element
import lustre/element/html.{html}
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

  // Handle the request!
  handle_request(req)
}

fn static_directory() -> String {
  let assert Ok(priv_directory) = wisp.priv_directory("futar_at_home")
  priv_directory <> "/static"
}

pub fn template(timetable lines: List(HtmlReadyTimetableLine)) {
  html.html([], [
    html.head([], [
      html.meta([attribute("charset", "utf-8")]),
      html.link([
        attribute("rel", "stylesheet"),
        attribute("href", "/static/style.css"),
      ]),
    ]),
    html.body([], [
      html.h1([], [element.text("Hello, Joe!")]),
      html.main([], [
        html.table([], [
          html.thead([], [
            html.tr([], [
              html.th([], [element.text("Line")]),
              html.th([], [element.text("Direction")]),
              html.th([], [element.text("Departs")]),
            ]),
          ]),
          html.tbody(
            [],
            lines
              |> list.map(fn(line) {
                html.tr([], [
                  html.td([], [element.text(line.line)]),
                  html.td([], [element.text(line.headsign)]),
                  html.td([], [element.text(line.departure)]),
                ])
              }),
          ),
        ]),
      ]),
    ]),
  ])
  |> element.to_string_builder
}
