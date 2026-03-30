// 주소 검색 위젯 진입점
// glendix/lustre TEA 패턴으로 dunji 카카오 우편번호 서비스 통합

import glendix/lustre as gl
import juso_search/model
import juso_search/props
import juso_search/update
import juso_search/view
import lustre/effect
import mendraw/mendix.{type JsProps}
import redraw.{type Element}
import redraw/ref

/// 위젯 메인 함수 - Mendix 런타임이 React 컴포넌트로 호출
pub fn widget(props: JsProps) -> Element {
  // Mendix props 추출
  let widget_props = props.extract(props)

  // 임베드 모드용 고유 ID (다중 인스턴스 지원)
  let embed_id = "juso-embed-" <> redraw.use_id()

  // Ref로 최신 props 유지 (stale closure 방지)
  let props_ref = redraw.use_ref_(widget_props)
  ref.assign(props_ref, widget_props)

  // TEA 패턴: Model → Update → View
  gl.use_tea(
    #(model.init(), effect.none()),
    fn(m, msg) { update.update(m, msg, props_ref, embed_id) },
    fn(m) { view.view(m, widget_props, embed_id) },
  )
}
