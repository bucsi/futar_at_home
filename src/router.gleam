import wisp.{type Request, type Response}

import controller/timetable
import internal/web

pub fn handle_request(req: Request, api_key: String) -> Response {
  use req <- web.middleware(req)

  case wisp.path_segments(req) {
    [] -> timetable.handle(req, api_key)
    _ -> wisp.not_found()
  }
}
