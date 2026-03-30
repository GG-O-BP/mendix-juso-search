// Mendix Studio Pro 속성 패널 설정
// 모드별 속성 가시성 제어

import glendix/editor_config.{type Properties}
import mendraw/mendix.{type JsProps}

/// 속성 패널 설정 - Studio Pro에서 위젯 속성의 가시성을 제어
pub fn get_properties(
  _values: JsProps,
  default_properties: Properties,
  _platform: String,
) -> Properties {
  // 탭 UI로 속성 그룹 표시
  editor_config.transform_groups_into_tabs(default_properties)
}
