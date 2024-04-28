import wisp

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
