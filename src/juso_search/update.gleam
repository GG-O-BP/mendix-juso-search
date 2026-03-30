// TEA update 함수: 메시지 처리, dunji 이펙트, Mendix 속성 쓰기

import dunji
import dunji/address
import gleam/option.{None, Some}
import juso_search/model.{
  type Model, type Msg, GotAddress, GotClose, GotResize, GotSearch, Model,
  UserClickedConfirm, UserClickedEmbedSearch, UserClickedReset,
  UserClickedSearch, UserInputDetail, UserToggledDetail,
}
import juso_search/props.{type WidgetProps}
import lustre/effect.{type Effect}
import mendraw/mendix/action
import mendraw/mendix/editable_value as ev
import redraw/ref.{type Ref}

/// 메시지 처리 및 이펙트 반환
pub fn update(
  model: Model,
  msg: Msg,
  props_ref: Ref(WidgetProps),
  embed_id: String,
) -> #(Model, Effect(Msg)) {
  case msg {
    // 팝업 모드 검색 버튼 클릭
    UserClickedSearch -> {
      let wp = ref.current(props_ref)
      let opts = props.build_options(wp)
      #(
        model,
        dunji.open(
          options: opts,
          on_complete: GotAddress,
          on_close: Some(GotClose),
          on_search: Some(GotSearch),
        ),
      )
    }

    // 임베드 모드 검색 시작
    UserClickedEmbedSearch -> {
      let wp = ref.current(props_ref)
      let opts = props.build_options(wp)
      #(
        Model(..model, embed_visible: True),
        dunji.embed(
          selector: "#" <> embed_id,
          options: opts,
          on_complete: GotAddress,
          on_close: Some(GotClose),
          on_resize: Some(GotResize),
          on_search: Some(GotSearch),
        ),
      )
    }

    // 주소 선택 완료
    GotAddress(addr) -> {
      #(
        Model(..model, address: Some(addr), embed_visible: False),
        write_address_to_mendix(addr, props_ref),
      )
    }

    // 닫힘 콜백
    GotClose(state) -> {
      #(
        Model(..model, close_state: Some(state), embed_visible: False),
        execute_close_action(props_ref),
      )
    }

    // 검색 콜백
    GotSearch(data) -> {
      #(Model(..model, search_data: Some(data)), effect.none())
    }

    // 리사이즈 콜백 (임베드)
    GotResize(size) -> {
      #(Model(..model, embed_size: Some(size)), effect.none())
    }

    // 상세주소 입력
    UserInputDetail(text) -> {
      #(Model(..model, detail_address: text), effect.none())
    }

    // 확인 버튼 (상세주소 포함)
    UserClickedConfirm -> {
      #(model, write_detail_to_mendix(model, props_ref))
    }

    // 초기화
    UserClickedReset -> {
      #(
        Model(
          address: None,
          detail_address: "",
          embed_visible: False,
          search_data: None,
          close_state: None,
          embed_size: None,
          show_detail: False,
        ),
        effect.none(),
      )
    }

    // 상세 보기 토글
    UserToggledDetail -> {
      #(Model(..model, show_detail: !model.show_detail), effect.none())
    }
  }
}

/// 선택된 주소를 Mendix 엔티티 속성에 쓰기
fn write_address_to_mendix(
  addr: address.Address,
  props_ref: Ref(WidgetProps),
) -> Effect(Msg) {
  effect.from(fn(_dispatch) {
    let wp = ref.current(props_ref)
    write_attr(wp.zonecode_attr, addr.zonecode)
    write_attr(wp.address_attr, address.selected_address(addr))
    write_attr(wp.road_address_attr, addr.road_address)
    write_attr(wp.jibun_address_attr, addr.jibun_address)
    write_opt_attr(
      wp.address_english_attr,
      address.selected_address_english(addr),
    )
    write_attr(wp.sido_attr, addr.sido)
    write_attr(wp.sigungu_attr, addr.sigungu)
    write_opt_attr(wp.bname_attr, addr.bname)
    write_opt_attr(wp.building_name_attr, addr.building_name)
    action.execute_action(wp.on_select_action)
  })
}

/// 닫힘 액션 실행
fn execute_close_action(props_ref: Ref(WidgetProps)) -> Effect(Msg) {
  effect.from(fn(_dispatch) {
    let wp = ref.current(props_ref)
    action.execute_action(wp.on_close_action)
  })
}

/// 상세주소를 addressAttr에 추가 쓰기
fn write_detail_to_mendix(
  model: Model,
  props_ref: Ref(WidgetProps),
) -> Effect(Msg) {
  effect.from(fn(_dispatch) {
    let wp = ref.current(props_ref)
    case model.address, model.detail_address {
      Some(addr), detail if detail != "" -> {
        let full = address.selected_address(addr) <> " " <> detail
        write_attr(wp.address_attr, full)
        Nil
      }
      _, _ -> Nil
    }
  })
}

/// Option(EditableValue)에 String 값 쓰기
fn write_attr(attr: option.Option(ev.EditableValue), value: String) -> Nil {
  case attr {
    Some(a) -> {
      ev.set_value(a, Some(value))
      Nil
    }
    None -> Nil
  }
}

/// Option(EditableValue)에 Option(String) 값 쓰기
fn write_opt_attr(
  attr: option.Option(ev.EditableValue),
  value: option.Option(String),
) -> Nil {
  case attr, value {
    Some(a), Some(v) -> {
      ev.set_value(a, Some(v))
      Nil
    }
    Some(a), None -> {
      ev.set_value(a, None)
      Nil
    }
    None, _ -> Nil
  }
}
