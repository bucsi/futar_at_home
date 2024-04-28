import lustre/attribute
import lustre/element/html

pub fn use_lucide() {
  [
    html.script([attribute.src("https://unpkg.com/lucide@latest")], ""),
    html.script([], "lucide.createIcons()"),
  ]
}

pub fn lucide(icon name: String) {
  html.i([attribute.attribute("data-lucide", name)], [])
}
