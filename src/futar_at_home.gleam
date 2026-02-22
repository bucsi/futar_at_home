import dot_env
import dot_env/env
import gleam/erlang/process
import mist
import wisp
import wisp/wisp_mist

import futar_at_home/controller

const jokai_mor_utca_rendorseg = "BKK_F03392"

const matyasfold_repuloter_h = "BKK_19824287"

pub fn main() -> Nil {
  wisp.configure_logger()
  dot_env.load_default()
  let assert Ok(api_key) = env.get_string("FUTAR_API_KEY")
  let secret_key_base = api_key

  let assert Ok(_) =
    fn(request) {
      use <- wisp.log_request(request)
      use <- wisp.rescue_crashes
      use <- wisp.serve_static(request, "/static", static_directory())
      use request <- wisp.handle_head(request)

      case request |> wisp.path_segments {
        [] ->
          [jokai_mor_utca_rendorseg, matyasfold_repuloter_h]
          |> controller.render_timetable_for_stops(api_key)
        _ -> wisp.not_found()
      }
    }
    |> wisp_mist.handler(secret_key_base)
    |> mist.new
    |> mist.port(8000)
    |> mist.start

  process.sleep_forever()
}

fn static_directory() -> String {
  let assert Ok(priv_directory) = wisp.priv_directory("futar_at_home")
  priv_directory <> "/static"
}
