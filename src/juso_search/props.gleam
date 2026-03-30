// Mendix 속성 추출 및 dunji 옵션/테마 빌더

import dunji/options.{type Options}
import dunji/theme.{type Theme}
import gleam/float
import gleam/option.{type Option}
import mendraw/mendix.{type JsProps}
import mendraw/mendix/action.{type ActionValue}
import mendraw/mendix/editable_value.{type EditableValue}

/// 표시 모드
pub type DisplayMode {
  Popup
  Embed
}

/// Mendix props에서 추출한 위젯 설정
pub type WidgetProps {
  WidgetProps(
    // 일반
    display_mode: DisplayMode,
    button_label: String,
    initial_query: String,
    auto_close: Bool,
    // 주소 속성 바인딩
    zonecode_attr: Option(EditableValue),
    address_attr: Option(EditableValue),
    road_address_attr: Option(EditableValue),
    jibun_address_attr: Option(EditableValue),
    address_english_attr: Option(EditableValue),
    sido_attr: Option(EditableValue),
    sigungu_attr: Option(EditableValue),
    bname_attr: Option(EditableValue),
    building_name_attr: Option(EditableValue),
    // 액션
    on_select_action: Option(ActionValue),
    on_close_action: Option(ActionValue),
    // 표시 옵션
    width: Int,
    height: Int,
    animation: Bool,
    hide_map_btn: Bool,
    hide_eng_btn: Bool,
    always_show_eng_addr: Bool,
    max_suggest_items: Int,
    // 고급 옵션
    focus_input: Bool,
    shorthand: Bool,
    show_more_h_name: Bool,
    auto_mapping_road: Bool,
    auto_mapping_jibun: Bool,
    submit_mode: Bool,
    use_banner_link: Bool,
    please_read_guide: Int,
    please_read_guide_timer: String,
    use_percent_width: Bool,
    use_percent_height: Bool,
    min_width: Int,
    popup_title: String,
    popup_key: String,
    popup_left: Int,
    popup_top: Int,
    // 테마
    theme_bg_color: String,
    theme_search_bg_color: String,
    theme_content_bg_color: String,
    theme_page_bg_color: String,
    theme_text_color: String,
    theme_query_text_color: String,
    theme_postcode_text_color: String,
    theme_emph_text_color: String,
    theme_outline_color: String,
  )
}

/// JsProps에서 WidgetProps 추출
pub fn extract(props: JsProps) -> WidgetProps {
  let mode = case mendix.get_string_prop(props, "displayMode") {
    "embed" -> Embed
    _ -> Popup
  }

  WidgetProps(
    display_mode: mode,
    button_label: mendix.get_string_prop(props, "buttonLabel"),
    initial_query: mendix.get_string_prop(props, "initialQuery"),
    auto_close: mendix.get_prop_required(props, "autoClose"),
    zonecode_attr: mendix.get_prop(props, "zonecodeAttr"),
    address_attr: mendix.get_prop(props, "addressAttr"),
    road_address_attr: mendix.get_prop(props, "roadAddressAttr"),
    jibun_address_attr: mendix.get_prop(props, "jibunAddressAttr"),
    address_english_attr: mendix.get_prop(props, "addressEnglishAttr"),
    sido_attr: mendix.get_prop(props, "sidoAttr"),
    sigungu_attr: mendix.get_prop(props, "sigunguAttr"),
    bname_attr: mendix.get_prop(props, "bnameAttr"),
    building_name_attr: mendix.get_prop(props, "buildingNameAttr"),
    on_select_action: mendix.get_prop(props, "onSelectAction"),
    on_close_action: mendix.get_prop(props, "onCloseAction"),
    width: mendix.get_prop_required(props, "width"),
    height: mendix.get_prop_required(props, "height"),
    animation: mendix.get_prop_required(props, "animation"),
    hide_map_btn: mendix.get_prop_required(props, "hideMapBtn"),
    hide_eng_btn: mendix.get_prop_required(props, "hideEngBtn"),
    always_show_eng_addr: mendix.get_prop_required(props, "alwaysShowEngAddr"),
    max_suggest_items: mendix.get_prop_required(props, "maxSuggestItems"),
    focus_input: mendix.get_prop_required(props, "focusInput"),
    shorthand: mendix.get_prop_required(props, "shorthand"),
    show_more_h_name: mendix.get_prop_required(props, "showMoreHName"),
    auto_mapping_road: mendix.get_prop_required(props, "autoMappingRoad"),
    auto_mapping_jibun: mendix.get_prop_required(props, "autoMappingJibun"),
    submit_mode: mendix.get_prop_required(props, "submitMode"),
    use_banner_link: mendix.get_prop_required(props, "useBannerLink"),
    please_read_guide: mendix.get_prop_required(props, "pleaseReadGuide"),
    please_read_guide_timer: mendix.get_string_prop(
      props,
      "pleaseReadGuideTimer",
    ),
    use_percent_width: mendix.get_prop_required(props, "usePercentWidth"),
    use_percent_height: mendix.get_prop_required(props, "usePercentHeight"),
    min_width: mendix.get_prop_required(props, "minWidth"),
    popup_title: mendix.get_string_prop(props, "popupTitle"),
    popup_key: mendix.get_string_prop(props, "popupKey"),
    popup_left: mendix.get_prop_required(props, "popupLeft"),
    popup_top: mendix.get_prop_required(props, "popupTop"),
    theme_bg_color: mendix.get_string_prop(props, "themeBgColor"),
    theme_search_bg_color: mendix.get_string_prop(props, "themeSearchBgColor"),
    theme_content_bg_color: mendix.get_string_prop(props, "themeContentBgColor"),
    theme_page_bg_color: mendix.get_string_prop(props, "themePageBgColor"),
    theme_text_color: mendix.get_string_prop(props, "themeTextColor"),
    theme_query_text_color: mendix.get_string_prop(props, "themeQueryTextColor"),
    theme_postcode_text_color: mendix.get_string_prop(
      props,
      "themePostcodeTextColor",
    ),
    theme_emph_text_color: mendix.get_string_prop(props, "themeEmphTextColor"),
    theme_outline_color: mendix.get_string_prop(props, "themeOutlineColor"),
  )
}

/// WidgetProps에서 dunji Options 빌드
pub fn build_options(wp: WidgetProps) -> Options {
  let opts = options.default()

  // 크기 (px 또는 %)
  let opts = case wp.use_percent_width {
    True -> options.width_percent(opts, wp.width)
    False -> options.width(opts, wp.width)
  }
  let opts = case wp.use_percent_height {
    True -> options.height_percent(opts, wp.height)
    False -> options.height(opts, wp.height)
  }

  // 표시 옵션
  let opts =
    opts
    |> options.animation(wp.animation)
    |> options.focus_input(wp.focus_input)
    |> options.shorthand(wp.shorthand)
    |> options.hide_map_btn(wp.hide_map_btn)
    |> options.hide_eng_btn(wp.hide_eng_btn)
    |> options.always_show_eng_addr(wp.always_show_eng_addr)
    |> options.show_more_h_name(wp.show_more_h_name)
    |> options.max_suggest_items(wp.max_suggest_items)
    |> options.auto_mapping_road(wp.auto_mapping_road)
    |> options.auto_mapping_jibun(wp.auto_mapping_jibun)
    |> options.submit_mode(wp.submit_mode)
    |> options.use_banner_link(wp.use_banner_link)
    |> options.auto_close(wp.auto_close)

  // 조건부 옵션 (0 또는 빈 값이면 기본값 사용)
  let opts = case wp.min_width {
    0 -> opts
    n -> options.min_width(opts, n)
  }
  let opts = case wp.please_read_guide {
    0 -> opts
    n -> options.please_read_guide(opts, n)
  }
  let opts = case wp.please_read_guide_timer {
    "" -> opts
    s ->
      case float.parse(s) {
        Ok(f) -> options.please_read_guide_timer(opts, f)
        Error(_) -> opts
      }
  }
  let opts = case wp.initial_query {
    "" -> opts
    q -> options.query(opts, q)
  }
  let opts = case wp.popup_title {
    "" -> opts
    t -> options.popup_title(opts, t)
  }
  let opts = case wp.popup_key {
    "" -> opts
    k -> options.popup_key(opts, k)
  }
  let opts = case wp.popup_left {
    0 -> opts
    n -> options.left(opts, n)
  }
  let opts = case wp.popup_top {
    0 -> opts
    n -> options.top(opts, n)
  }

  // 테마 적용
  options.theme(opts, build_theme(wp))
}

/// WidgetProps에서 dunji Theme 빌드
pub fn build_theme(wp: WidgetProps) -> Theme {
  let t = theme.default()
  let t = apply_color(t, wp.theme_bg_color, theme.bg_color)
  let t = apply_color(t, wp.theme_search_bg_color, theme.search_bg_color)
  let t = apply_color(t, wp.theme_content_bg_color, theme.content_bg_color)
  let t = apply_color(t, wp.theme_page_bg_color, theme.page_bg_color)
  let t = apply_color(t, wp.theme_text_color, theme.text_color)
  let t = apply_color(t, wp.theme_query_text_color, theme.query_text_color)
  let t =
    apply_color(t, wp.theme_postcode_text_color, theme.postcode_text_color)
  let t = apply_color(t, wp.theme_emph_text_color, theme.emph_text_color)
  apply_color(t, wp.theme_outline_color, theme.outline_color)
}

/// 빈 문자열이 아닐 때만 테마 색상 적용
fn apply_color(
  t: Theme,
  color: String,
  setter: fn(Theme, String) -> Theme,
) -> Theme {
  case color {
    "" -> t
    c -> setter(t, c)
  }
}

/// 버튼 라벨 (빈 값이면 기본값)
pub fn button_label(wp: WidgetProps) -> String {
  case wp.button_label {
    "" -> "주소 검색"
    l -> l
  }
}
