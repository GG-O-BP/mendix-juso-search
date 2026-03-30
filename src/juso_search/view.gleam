// TEA view 함수: lustre 엘리먼트로 위젯 UI 렌더링
// Address 40필드 전체 표시, CloseState/SearchData/Size 활용

import dunji.{type Size, ForceClose, Size}
import dunji/address.{type Address, English, Jibun, Korean, Road}
import gleam/int
import gleam/option.{type Option, None, Some}
import juso_search/model.{
  type Model, type Msg, UserClickedConfirm, UserClickedEmbedSearch,
  UserClickedReset, UserClickedSearch, UserInputDetail, UserToggledDetail,
}
import juso_search/props.{type WidgetProps, Embed, Popup}
import lustre/attribute
import lustre/element.{type Element}
import lustre/element/html
import lustre/event

/// 메인 뷰 함수
pub fn view(model: Model, wp: WidgetProps, embed_id: String) -> Element(Msg) {
  html.div([attribute.class("juso-search")], [
    // 닫힘 상태 메시지 (ForceClose일 때만)
    view_close_message(model),
    // 검색 영역 (모드별)
    view_search_area(model, wp, embed_id),
    // 선택된 주소 결과
    view_result(model),
    // 검색 상태 정보
    view_search_info(model),
  ])
}

/// CloseState 메시지 표시
fn view_close_message(model: Model) -> Element(Msg) {
  case model.close_state, model.address {
    // ForceClose이고 주소 미선택 → 취소 메시지
    Some(ForceClose), None ->
      html.div([attribute.class("juso-search-close-msg")], [
        html.text("검색이 취소되었습니다"),
      ])
    // CompleteClose이거나 주소가 선택된 상태 → 메시지 없음
    _, _ -> element.none()
  }
}

/// 검색 영역 렌더링 (팝업/임베드 모드)
fn view_search_area(
  model: Model,
  wp: WidgetProps,
  embed_id: String,
) -> Element(Msg) {
  let label = props.button_label(wp)

  case wp.display_mode {
    Popup -> view_popup_area(model, label)
    Embed -> view_embed_area(model, label, embed_id, model.embed_size)
  }
}

/// 팝업 모드: 검색 버튼
fn view_popup_area(model: Model, label: String) -> Element(Msg) {
  case model.address {
    None ->
      html.button(
        [
          attribute.class("juso-search-btn"),
          event.on_click(UserClickedSearch),
        ],
        [html.text(label)],
      )
    Some(_) -> element.none()
  }
}

/// 임베드 모드: 검색 버튼 + 임베드 컨테이너 (Size 반영)
fn view_embed_area(
  model: Model,
  label: String,
  embed_id: String,
  size: Option(Size),
) -> Element(Msg) {
  case model.address {
    None ->
      html.div([attribute.class("juso-search-embed-area")], [
        case model.embed_visible {
          False ->
            html.button(
              [
                attribute.class("juso-search-btn"),
                event.on_click(UserClickedEmbedSearch),
              ],
              [html.text(label)],
            )
          True -> element.none()
        },
        case model.embed_visible {
          True -> {
            // on_resize로 받은 Size를 컨테이너 높이에 반영
            let style_attrs = case size {
              Some(Size(width: w, height: h)) -> [
                attribute.id(embed_id),
                attribute.class("juso-search-embed-container"),
                attribute.style("width", int.to_string(w) <> "px"),
                attribute.style("height", int.to_string(h) <> "px"),
              ]
              None -> [
                attribute.id(embed_id),
                attribute.class("juso-search-embed-container"),
              ]
            }
            html.div(style_attrs, [])
          }
          False -> element.none()
        },
      ])
    Some(_) -> element.none()
  }
}

/// 선택된 주소 결과 표시 (요약 + 상세 토글)
fn view_result(model: Model) -> Element(Msg) {
  case model.address {
    None -> element.none()
    Some(addr) ->
      html.div([attribute.class("juso-search-result")], [
        // 요약 영역 (항상 표시)
        view_summary(addr),
        // 상세 보기 토글 버튼
        html.button(
          [
            attribute.class("juso-search-detail-toggle"),
            event.on_click(UserToggledDetail),
          ],
          [
            case model.show_detail {
              True -> html.text("상세 접기")
              False -> html.text("상세 보기")
            },
          ],
        ),
        // 상세 필드 (토글)
        case model.show_detail {
          True -> view_detail_fields(addr)
          False -> element.none()
        },
        // 상세주소 입력
        html.div([attribute.class("juso-search-detail-input-area")], [
          html.input([
            attribute.type_("text"),
            attribute.class("juso-search-detail__input"),
            attribute.value(model.detail_address),
            attribute.placeholder("상세주소 입력 (동/호수)"),
            event.on_input(UserInputDetail),
          ]),
        ]),
        // 액션 버튼
        html.div([attribute.class("juso-search-actions")], [
          html.button(
            [
              attribute.class("juso-search-actions__confirm"),
              event.on_click(UserClickedConfirm),
            ],
            [html.text("확인")],
          ),
          html.button(
            [
              attribute.class("juso-search-actions__reset"),
              event.on_click(UserClickedReset),
            ],
            [html.text("다시 검색")],
          ),
        ]),
      ])
  }
}

/// 요약 영역: 우편번호, 선택 주소, 영문 주소, 주소 유형, 검색 언어
fn view_summary(addr: Address) -> Element(Msg) {
  html.div([attribute.class("juso-search-summary")], [
    row("우편번호", addr.zonecode),
    row("주소", address.selected_address(addr)),
    opt_row("영문 주소", address.selected_address_english(addr)),
    row("주소 유형", address_type_label(addr.user_selected_type)),
    row("검색 언어", language_type_label(addr.user_language_type)),
  ])
}

/// 상세 필드: Address 40필드를 섹션별 그룹화
fn view_detail_fields(addr: Address) -> Element(Msg) {
  html.div([attribute.class("juso-search-fields")], [
    // 도로명주소 섹션
    section("도로명주소", [
      row("도로명주소", addr.road_address),
      opt_row("도로명주소 (영문)", addr.road_address_english),
      opt_row("추천 도로명주소", addr.auto_road_address),
      opt_row("추천 도로명주소 (영문)", addr.auto_road_address_english),
      opt_row("도로명", addr.roadname),
      opt_row("도로명 (영문)", addr.roadname_english),
      opt_row("도로명 코드", addr.roadname_code),
    ]),
    // 지번주소 섹션
    section("지번주소", [
      row("지번주소", addr.jibun_address),
      opt_row("지번주소 (영문)", addr.jibun_address_english),
      opt_row("추천 지번주소", addr.auto_jibun_address),
      opt_row("추천 지번주소 (영문)", addr.auto_jibun_address_english),
    ]),
    // 행정구역 섹션
    section("행정구역", [
      row("시/도", addr.sido),
      row("시/도 (영문)", addr.sido_english),
      row("시/군/구", addr.sigungu),
      row("시/군/구 (영문)", addr.sigungu_english),
      row("시/군/구 코드", addr.sigungu_code),
    ]),
    // 동/리 섹션
    section("동/리", [
      opt_row("법정동/리", addr.bname),
      opt_row("법정동/리 (영문)", addr.bname_english),
      opt_row("읍/면", addr.bname1),
      opt_row("읍/면 (영문)", addr.bname1_english),
      opt_row("법정동", addr.bname2),
      opt_row("법정동 (영문)", addr.bname2_english),
      opt_row("행정동", addr.hname),
    ]),
    // 건물 정보 섹션
    section("건물 정보", [
      opt_row("건물명", addr.building_name),
      opt_row("건물관리번호", addr.building_code),
      row("공동주택", bool_label(addr.apartment)),
      row("법정동 코드", addr.bcode),
    ]),
    // 기타 섹션
    section("기타", [
      row("기본 주소", addr.address),
      row("기본 주소 (영문)", addr.address_english),
      row("주소 유형 (기본)", address_type_label(addr.address_type)),
      row("검색어", addr.query),
      row("선택 안함 클릭", bool_label(addr.no_selected)),
    ]),
  ])
}

/// 검색 상태 정보 (검색어 + 건수)
fn view_search_info(model: Model) -> Element(Msg) {
  case model.search_data {
    Some(data) ->
      html.div([attribute.class("juso-search-info")], [
        html.text(
          "'" <> data.query <> "' 검색결과: " <> int.to_string(data.count) <> "건",
        ),
      ])
    None -> element.none()
  }
}

// ── 헬퍼 함수 ──

/// AddressType → 한글 라벨
fn address_type_label(t: address.AddressType) -> String {
  case t {
    Road -> "도로명"
    Jibun -> "지번"
  }
}

/// LanguageType → 한글 라벨
fn language_type_label(t: address.LanguageType) -> String {
  case t {
    Korean -> "한국어"
    English -> "영어"
  }
}

/// Bool → 한글 라벨
fn bool_label(b: Bool) -> String {
  case b {
    True -> "예"
    False -> "아니오"
  }
}

/// 라벨-값 한 행
fn row(label: String, value: String) -> Element(Msg) {
  html.div([attribute.class("juso-search-row")], [
    html.span([attribute.class("juso-search-row__label")], [html.text(label)]),
    html.span([attribute.class("juso-search-row__value")], [html.text(value)]),
  ])
}

/// Option(String) 값이 있을 때만 표시하는 행
fn opt_row(label: String, value: Option(String)) -> Element(Msg) {
  case value {
    Some(v) -> row(label, v)
    None -> element.none()
  }
}

/// 섹션 헤더 + 필드들
fn section(title: String, children: List(Element(Msg))) -> Element(Msg) {
  html.div([attribute.class("juso-search-section")], [
    html.h4([attribute.class("juso-search-section__title")], [
      html.text(title),
    ]),
    html.div([attribute.class("juso-search-section__body")], children),
  ])
}
