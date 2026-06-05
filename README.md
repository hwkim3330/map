# 클릭 → GPS 좌표 (OSM / Naver / Kakao / Google / VWorld)

지도를 클릭하면 그 지점의 **위도·경도(WGS84)** 를 보여주는 정적 웹앱.
구글맵의 "우클릭 → 좌표"를, 한국에서 자주 쓰는 지도들에 대해 제공합니다.

**탭 5개:** OSM(키 불필요), Naver, Kakao, Google, VWorld
**기능:** 좌표 복사 / `경도,위도` 복사 · 역지오코딩(주소) · 주소·장소 검색 · 내 위치 📍
· **거리 측정**(여러 점) · **지점 저장**(localStorage) · **CSV/GeoJSON 내보내기** · **공유 링크**(`#위도,경도,줌,탭`)

> OSM 탭은 **키 없이 바로 동작**합니다. 나머지는 각 사의 키 + **도메인 등록**이 필요합니다.

---

## ⭐ 핵심: "키 노출" 문제에 대한 정답

지도를 브라우저에 띄우려면 **JavaScript 키는 반드시 브라우저로 전송**됩니다. GitHub Pages든
어디든, 소스에서 빼서 따로 주입해도 결국 네트워크/페이지 소스에 보입니다. **카카오·네이버·구글
모두 마찬가지이고 우회 방법이 없습니다.**

→ 그래서 진짜 보안 장치는 "키 숨기기"가 아니라 **콘솔의 도메인(화이트리스트) 등록**입니다.

**카카오:** [developers.kakao.com](https://developers.kakao.com) → 내 애플리케이션 → 앱 선택
→ **플랫폼 → Web → 사이트 도메인** 에 배포 주소 등록:
```
https://hwkim3330.github.io
http://localhost:8000      ← 로컬 테스트용
```
등록하면 그 키는 **해당 도메인에서만 작동** → 남이 복사해 자기 사이트에 박아도 안 됩니다.
**즉, 공개 레포에 키가 있어도 무해해집니다.** (네이버·VWorld도 동일하게 도메인 등록 필수)

> REST 키(주소·키워드 검색용)는 **숨겨야 하는 키**라 다릅니다 → 아래 [Cloudflare Worker](#4-카카오-rest-프록시-cloudflare-worker-선택) 참고.

---

## 1. 키 발급

| 지도 | 발급처 | 키 종류 | 도메인 등록 |
|---|---|---|---|
| **Naver** | [console.ncloud.com](https://www.ncloud.com) → Maps | Web Dynamic Map (`ncpKeyId`) | 서비스 URL 필수 |
| **Kakao** | [developers.kakao.com](https://developers.kakao.com) | **JavaScript 키** (지도용) / **REST API 키** (검색용) | Web 플랫폼 도메인 필수 |
| **Google** | [console.cloud.google.com](https://console.cloud.google.com) | Maps JavaScript API 키 | HTTP 리퍼러 제한 권장 |
| **VWorld** | [vworld.kr](https://www.vworld.kr) → 오픈API → 인증키 | 2D/WMTS 인증키 | 사용 도메인 필수 |

> 네이버는 콘솔 버전에 따라 `ncpKeyId`(신규) 또는 `ncpClientId`(구버전). 이 앱은 신규 `ncpKeyId` 기준.
> 구버전이면 `index.html`의 `initNaver` 안 `ncpKeyId=` → `ncpClientId=` 로 변경.

## 2. 키 넣는 방법 (두 가지)

**A. 로컬/간단 — 직접 입력**
`index.html` 상단 `window.MAP_KEYS` 의 `__XXX__` 자리에 키를 바로 적습니다.

**B. 배포 — GitHub Actions 주입 (키를 git 소스에 안 남김)**
`__XXX__` 플레이스홀더를 그대로 두고, 레포 Secrets 에 키를 넣으면 배포 시 자동 치환됩니다 → [3번](#3-github-pages-자동-배포-actions).

```js
window.MAP_KEYS = {
  NAVER:  "__NAVER_KEY__",
  KAKAO:  "__KAKAO_KEY__",
  GOOGLE: "__GOOGLE_KEY__",
  VWORLD: "__VWORLD_KEY__",
  PROXY:  "__PROXY_URL__"   // (선택) 카카오 REST 프록시
};
```

## 3. GitHub Pages 자동 배포 (Actions)

`.github/workflows/deploy.yml` 이 포함되어 있습니다. push 하면 키를 주입해 Pages 로 배포합니다.

1. **레포 Settings → Pages → Source = "GitHub Actions"**
2. **레포 Settings → Secrets and variables → Actions** 에 시크릿 추가:
   - `KAKAO_KEY` (필수) · `NAVER_KEY` · `GOOGLE_KEY` · `VWORLD_KEY` · `PROXY_URL` (선택)
3. `main` 브랜치에 push → 자동 빌드·배포 → `https://hwkim3330.github.io/map/`
4. 그 주소를 **카카오/네이버/VWorld 콘솔 도메인에 등록** (안 하면 지도 안 뜸)

> 시크릿을 안 넣은 키는 빈 값으로 처리되어 해당 탭만 "키 필요" 안내가 뜹니다(앱은 정상).
> 다시 강조: Actions 주입은 git 히스토리에서만 가립니다. 배포 페이지엔 보이므로 **도메인 등록이 본질**입니다.

## 4. 카카오 REST 프록시 (Cloudflare Worker, 선택)

OSM Nominatim 대신 **카카오의 정확한 한국 주소·장소 검색**을 쓰고 싶을 때.
REST 키는 노출되면 안 되므로 작은 프록시(Worker)가 대신 호출합니다. `worker/` 폴더 참고.

```bash
cd worker
npm i -g wrangler
wrangler login
wrangler secret put KAKAO_REST_KEY      # 카카오 REST API 키 입력
# wrangler.toml 의 ALLOW_ORIGINS 를 배포 도메인으로 수정
wrangler deploy
```
→ 출력된 `https://kakao-proxy.<you>.workers.dev` 를 `MAP_KEYS.PROXY` 또는 Secret `PROXY_URL` 에 넣기.
PROXY 가 설정되면 검색·역지오코딩이 카카오로 전환됩니다(없으면 Nominatim).

## 5. Apple Watch 앱 (선택, 별도 프로젝트)

워치에서 **현재 내 위치 좌표**를 보고 아이폰으로 보내 복사하는 SwiftUI 앱. `watch/` 폴더와
[watch/README.md](watch/README.md) 참고. **macOS + Xcode + Apple Developer 계정** 필요.

---

## 로컬에서 보기
```bash
python3 -m http.server 8000   # 또는: npx serve .
```
→ `http://localhost:8000` (OSM은 바로 됨. 카카오 등은 `localhost`도 콘솔 도메인에 등록)

## 좌표계 참고
- 표시 좌표는 모두 **WGS84 위경도(EPSG:4326)** — GPS/구글맵과 동일.
- 카카오·네이버 내부 좌표도 위경도로 받아 변환 없이 표시.
- 역지오코딩/검색은 기본 OSM Nominatim(무료, 호출 제한 있음). PROXY 설정 시 카카오.

## 디렉터리
```
map/
├── index.html                  # 웹앱(단일 파일)
├── .github/workflows/deploy.yml# Pages 배포 + 키 주입
├── worker/                     # 카카오 REST 프록시(Cloudflare Worker)
│   ├── kakao-proxy.js
│   └── wrangler.toml
└── watch/                      # Apple Watch 앱(SwiftUI)
    ├── GpsWatchApp.swift / ContentView.swift / LocationManager.swift / PhoneBridge.swift
    ├── ios-companion/PhoneApp.swift
    └── README.md
```
