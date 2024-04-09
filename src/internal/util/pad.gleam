import gleam/string

pub type Padding {
  PadLeft
  PadRight
  Center
}

pub fn pad(string: String, padding kind: Padding, desired lenght: Int) {
  case kind {
    PadLeft -> pad_left(string, lenght)
    PadRight -> pad_right(string, lenght)
    Center -> center(string, lenght)
  }
}

fn pad_left(string: String, desired_lenght: Int) {
  let original_length = string.length(string)
  let spaces_to_add = desired_lenght - original_length
  string.repeat(" ", spaces_to_add) <> string
}

fn pad_right(string: String, desired_lenght: Int) {
  todo
}

fn center(string: String, desired_lenght: Int) {
  todo
}
