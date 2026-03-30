// Mendix Studio Pro 디자인 뷰 미리보기
// 위젯의 시각적 미리보기를 렌더링 (React 직접 사용)

import mendraw/mendix.{type JsProps}
import redraw.{type Element}
import redraw/dom/attribute
import redraw/dom/html

/// Studio Pro 디자인 뷰 미리보기
pub fn preview(props: JsProps) -> Element {
  let mode = mendix.get_string_prop(props, "displayMode")
  let label = case mendix.get_string_prop(props, "buttonLabel") {
    "" -> "주소 검색"
    l -> l
  }

  case mode {
    "embed" ->
      html.div([attribute.class("juso-search juso-search-preview")], [
        html.div([attribute.class("juso-search-embed-placeholder")], [
          html.text("[주소 검색 임베드 영역]"),
        ]),
      ])
    _ ->
      html.div([attribute.class("juso-search juso-search-preview")], [
        html.button([attribute.class("juso-search-btn")], [html.text(label)]),
      ])
  }
}
