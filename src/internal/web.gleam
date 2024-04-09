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
      html.meta([
        attribute("name", "viewport"),
        attribute("content", "width=device-width, initial-scale=1"),
      ]),
      html.link([
        attribute("rel", "stylesheet"),
        attribute("href", "/static/style.css"),
      ]),
      html.link([
        attribute("rel", "icon"),
        attribute("href", "/static/favicon.ico"),
      ]),
      html.title([], "Futár@home"),
    ]),
    html.body([], [
      html.h1([], [
        element.text(
          "Mátyásföld, Rendőrség | Mátyásföld, Repülőtér H",
        ),
      ]),
      html.main([], [
        html.table([], [
          html.thead([], [
            html.tr([], [
              html.th([], [element.text("Line")]),
              html.th([], [element.text("Destination")]),
              html.th([], [element.text("Departs")]),
            ]),
          ]),
          html.tbody(
            [],
            lines
              |> list.map(fn(line) {
                html.tr([], [
                  html.td([], [
                    html.div(
                      [
                        attribute("class", "line-number"),
                        attribute("style", "background-color: " <> line.color),
                      ],
                      [element.text(line.line)],
                    ),
                  ]),
                  html.td([], [
                    html.span([attribute("class", "destination-chevron")], [
                      element.text("▶ "),
                    ]),
                    html.span([], [element.text(line.headsign)]),
                  ]),
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
