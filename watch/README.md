# Apple Watch 앱 — 내 GPS 좌표 보기

워치에서 **현재 내 위치(위도·경도, WGS84)** 와 주소를 보고, 페어링된 아이폰으로 좌표를 보내
클립보드에 복사하는 SwiftUI 앱입니다.

> ⚠️ **웹앱과 별개 프로젝트입니다.** 워치 앱은 네이티브라서 **macOS + Xcode + Apple Developer 계정**이 필요합니다.
> 또한 워치는 화면이 작아 "지도 클릭으로 좌표 따기"는 부적합 → 워치에선 "내 위치 좌표 보기"로 설계했습니다.

## 필요한 것
- macOS + Xcode 15 이상
- Apple Developer 계정 (실기기 설치 시 $99/년. 시뮬레이터 테스트는 무료)
- 페어링된 Apple Watch (실기기 위치 테스트용. 시뮬레이터는 위치 시뮬 가능)

## 만드는 순서

1. **Xcode → File → New → Project → watchOS → App** 선택
   - Product Name: `GpsWatch`
   - 인터페이스: SwiftUI, 언어: Swift
   - "Watch-only App" 또는 iOS와 함께 만들고 싶으면 아래 컴패니언 참고

2. **소스 교체** — 생성된 워치 타깃에 이 폴더 파일을 추가/교체:
   - `GpsWatchApp.swift`
   - `ContentView.swift`
   - `LocationManager.swift`
   - `PhoneBridge.swift` (아이폰 전송용. 컴패니언 안 쓰면 빼도 됨 — ContentView의 "아이폰으로 복사" 버튼도 같이 제거)

3. **위치 권한 문구 추가** — 워치 타깃 Info 설정에 키 추가:
   - `NSLocationWhenInUseUsageDescription` = `현재 위치 좌표를 표시하기 위해 위치를 사용합니다`

4. **빌드 & 실행** — 워치 시뮬레이터(또는 실기기) 선택 후 ▶︎
   - 시뮬레이터에서 위치가 안 잡히면: 시뮬레이터 메뉴 **Features → Location → Custom Location** 으로 좌표 주입

## (선택) 아이폰 컴패니언 — 클립보드 복사
워치에는 시스템 클립보드가 없습니다. 좌표를 "복사"하려면 아이폰이 받아서 복사해야 합니다.
- `ios-companion/PhoneApp.swift` 를 iOS 타깃에 추가
- iOS 타깃에도 `WatchConnectivity` 사용 (기본 포함)
- 워치에서 "아이폰으로 복사" → 아이폰 앱이 자동으로 `UIPasteboard` 에 복사

컴패니언 없이도 워치에서 좌표 **확인**은 됩니다(복사만 안 됨).

## 확장 아이디어
- 저장 지점 목록(워치 ↔ 아이폰 ↔ 웹앱 동기화: iCloud Key-Value 또는 공유 App Group)
- Complication(워치 페이스에 현재 좌표/거리 표시)
- 웹앱의 `#lat,lng,zoom` 공유 링크를 아이폰에서 열기
