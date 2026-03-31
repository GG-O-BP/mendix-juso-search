// 위젯 상태 모델과 메시지 타입 정의

import dunji.{type CloseState, type SearchData, type Size}
import dunji/address.{type Address}
import gleam/option.{type Option, None}

/// 위젯 상태
pub type Model {
  Model(
    address: Option(Address),
    close_state: Option(CloseState),
    search_data: Option(SearchData),
    embed_size: Option(Size),
    detail_address: String,
    embed_visible: Bool,
    show_detail: Bool,
  )
}

/// 메시지 타입
pub type Msg {
  // 사용자 액션
  UserClickedSearch
  UserClickedEmbedSearch
  UserInputDetail(String)
  UserClickedConfirm
  UserClickedReset
  UserToggledDetail
  UserClosedModal
  // dunji 콜백
  GotAddress(Address)
  GotClose(CloseState)
  GotSearch(SearchData)
  GotResize(Size)
}

/// 초기 모델
pub fn init() -> Model {
  Model(
    address: None,
    close_state: None,
    search_data: None,
    embed_size: None,
    detail_address: "",
    embed_visible: False,
    show_detail: False,
  )
}
