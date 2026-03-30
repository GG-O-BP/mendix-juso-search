# JusoSearch

카카오 우편번호 서비스를 활용한 한국 주소 검색 Mendix Pluggable Widget.
[dunji](https://hexdocs.pm/dunji/) 패키지의 전체 기능을 Gleam + TEA 패턴으로 구현했다.

## 기능

- **팝업/임베드 모드** — 카카오 우편번호 서비스를 팝업 또는 페이지 내 임베드로 표시
- **주소 데이터 바인딩** — 선택된 주소(우편번호, 도로명, 지번, 시/도, 시/군/구, 법정동, 건물명, 영문 주소)를 Mendix 엔티티 속성에 자동 저장
- **상세주소 입력** — 주소 선택 후 동/호수 등 상세주소 입력 지원
- **전체 옵션** — 크기, 애니메이션, 자동 포커스, 시/도 약칭, 지도/영문 버튼 표시, 추천 항목 수 등 카카오 우편번호 서비스의 모든 옵션 지원
- **테마** — 배경색, 텍스트색, 검색창색, 강조색, 테두리색 등 9가지 색상 커스터마이징
- **콜백** — 주소 선택(`on_complete`), 닫힘(`on_close`), 검색(`on_search`), 리사이즈(`on_resize`) 이벤트 처리
- **Address 40필드 표시** — 접이식 상세 보기로 도로명/지번/행정구역/동리/건물 정보 전체 표시
- **Mendix 액션** — 주소 선택/닫힘 시 마이크로플로우/나노플로우 실행

## 사전 요구사항

- [Gleam](https://gleam.run/getting-started/installing/)
- [Node.js](https://nodejs.org/) (v18+)
- [bun](https://bun.sh/)

## 설치

```bash
gleam run -m glendix/install
```

## 명령어

```bash
gleam run -m glendix/dev          # 개발 서버 (HMR, 포트 3000)
gleam run -m glendix/build        # 프로덕션 빌드 (.mpk 출력)
gleam run -m glendix/start        # Mendix 테스트 프로젝트 연동
gleam run -m glendix/release      # 릴리즈 빌드
gleam run -m glendix/lint         # ESLint
gleam run -m glendix/lint_fix     # ESLint 자동 수정
gleam test                        # 테스트
gleam format                      # 코드 포맷팅
```

빌드 결과물(`.mpk`)은 `dist/` 디렉토리에 생성된다.

## 프로젝트 구조

```
src/
  juso_search.gleam              # 위젯 진입점 (use_tea + use_ref)
  juso_search/
    model.gleam                  # Model, Msg 타입 정의
    update.gleam                 # TEA update (dunji 호출 + Mendix 속성 쓰기)
    view.gleam                   # TEA view (팝업/임베드 UI + 주소 40필드 표시)
    props.gleam                  # Mendix props 추출, 옵션/테마 빌더
  editor_config.gleam            # Studio Pro 속성 패널 설정
  editor_preview.gleam           # Studio Pro 디자인 뷰 미리보기
  ui/
    JusoSearch.css               # 위젯 스타일
  JusoSearch.xml                 # Mendix 위젯 속성 정의 (47개)
  package.xml                    # Mendix 패키지 매니페스트
```

## 아키텍처

```
Mendix Runtime
  → widget(JsProps) → extract_props → use_ref(props)
    → glendix/lustre.use_tea(init, update, view)
      → Model ←→ Update(dunji Effect) ←→ View(lustre Element)
    → React Element → DOM
```

- **TEA 패턴**: `glendix/lustre.use_tea`로 lustre의 Model-Update-View를 React 컴포넌트에 통합
- **Stale Closure 방지**: `redraw.use_ref_`로 최신 Mendix props를 `Ref`에 보관. `update` 클로저에서 `ref.current`로 항상 최신 값 접근
- **dunji 통합**: `update` 함수에서 `dunji.open`/`dunji.embed`이 `Effect(Msg)`를 반환하면, `use_tea`의 React `useEffect`가 이를 실행하고 콜백 결과를 `dispatch`로 다시 `update`에 전달

## Mendix 속성

위젯을 Mendix Studio Pro에 배치하면 6개 탭으로 구성된 속성 패널이 표시된다.

### General

| 속성 | 타입 | 기본값 | 설명 |
|------|------|--------|------|
| Display mode | enumeration | `popup` | Popup 또는 Embed |
| Button label | string | `""` | 검색 버튼 텍스트 (빈 값 = "주소 검색") |
| Initial query | string | `""` | 초기 검색어 |
| Auto close | boolean | `true` | 주소 선택 후 자동 닫기 |

### Address attributes

선택된 주소를 Mendix 엔티티의 String 속성에 바인딩한다. 모두 선택 사항.

| 속성 | 저장 값 |
|------|---------|
| Zonecode | 우편번호 (5자리) |
| Address | 사용자 선택 기준 주소 (`selected_address`) |
| Road address | 도로명주소 |
| Jibun address | 지번주소 |
| English address | 영문 주소 (`selected_address_english`) |
| Sido | 시/도 |
| Sigungu | 시/군/구 |
| Bname | 법정동/리 |
| Building name | 건물명 |

### Actions

| 속성 | 설명 |
|------|------|
| On select | 주소 선택 완료 후 실행할 마이크로플로우/나노플로우 |
| On close | 검색 창 닫힘 시 실행할 액션 |

### Display options

| 속성 | 타입 | 기본값 | 설명 |
|------|------|--------|------|
| Width | integer | `500` | 너비 (px 또는 %) |
| Height | integer | `500` | 높이 (px 또는 %) |
| Animation | boolean | `false` | 애니메이션 효과 |
| Hide map button | boolean | `false` | 지도 버튼 숨김 |
| Hide English button | boolean | `false` | 영문 전환 버튼 숨김 |
| Always show English | boolean | `false` | 영문 주소 항상 표시 |
| Max suggestions | integer | `10` | 최대 추천 항목 수 (1-10) |

### Advanced options

| 속성 | 타입 | 기본값 | 설명 |
|------|------|--------|------|
| Focus input | boolean | `true` | 검색창 자동 포커스 (PC 전용) |
| Shorthand | boolean | `true` | 시/도 약칭 (서울특별시 → 서울) |
| Show admin dong | boolean | `false` | 행정동명 표시 |
| Auto mapping road | boolean | `true` | 도로명 1:N 매핑 시 "선택 안함" 표시 |
| Auto mapping jibun | boolean | `true` | 지번 1:N 매핑 시 "선택 안함" 표시 |
| Submit mode | boolean | `true` | 폼 submit 모드 |
| Banner link | boolean | `true` | 하단 배너 링크 |
| Guide emphasis | integer | `0` | 가이드 강조 페이지 수 (3-20, 0=비활성) |
| Guide timer | string | `""` | 가이드 강조 시간(초) (빈 값=1.5) |
| Width as percent | boolean | `false` | 너비를 퍼센트로 사용 |
| Height as percent | boolean | `false` | 높이를 퍼센트로 사용 |
| Min width | integer | `0` | 최소 너비 px (0=기본값 300) |
| Popup title | string | `""` | 팝업 창 제목 |
| Popup key | string | `""` | 중복 팝업 방지 키 |
| Popup left | integer | `0` | 팝업 X 좌표 (0=기본) |
| Popup top | integer | `0` | 팝업 Y 좌표 (0=기본) |

### Theme

9가지 색상을 CSS 색상 코드(예: `#264AE5`)로 지정한다. 빈 값이면 카카오 기본 테마를 사용한다.

| 속성 | 대상 |
|------|------|
| Background | 전체 배경 |
| Search background | 검색창 배경 |
| Content background | 콘텐츠 영역 배경 |
| Page background | 페이지 배경 |
| Text color | 기본 텍스트 |
| Query text color | 검색어 텍스트 |
| Postcode text color | 우편번호 텍스트 |
| Emphasis text color | 강조 텍스트 |
| Outline color | 테두리 |

## 기술 스택

- **[Gleam](https://gleam.run/)** → JavaScript 컴파일
- **[glendix](https://hexdocs.pm/glendix/)** — Mendix 위젯 빌드 도구 + lustre 브릿지
- **[mendraw](https://hexdocs.pm/mendraw/)** — Mendix API Gleam 바인딩
- **[dunji](https://hexdocs.pm/dunji/)** — 카카오 우편번호 서비스 Gleam 래퍼 (lustre Effect 기반)
- **[redraw](https://hexdocs.pm/redraw/)** / **[redraw_dom](https://hexdocs.pm/redraw_dom/)** — React 19 Gleam 바인딩
- **[lustre](https://hexdocs.pm/lustre/)** — TEA (The Elm Architecture) 프레임워크

## 라이센스

[Blue Oak Model License 1.0.0](https://blueoakcouncil.org/license/1.0.0)
