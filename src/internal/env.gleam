import dot_env
import dot_env/env

pub fn load() -> String {
  dot_env.load()

  case env.get("FUTAR_API_KEY") {
    Ok(api_key) -> api_key
    Error(_) -> panic as "FUTAR_API_KEY could not be read from the .env file!"
  }
}
