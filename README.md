# 클릭 → GPS 좌표 (Naver / Kakao / Google / VWorld / OSM)

지도를 마우스로 클릭하면 그 지점의 **위도·경도(WGS84)** 를 보여주는 정적 웹앱.
구글맵의 "우클릭 → 좌표"와 같은 기능을, 한국에서 자주 쓰는 지도들에 대해 제공합니다.

탭 5개: **OSM(키 불필요), Naver, Kakao, Google, VWorld**
부가 기능: 좌표 복사, `경도,위도` 순서 복사, 클릭 지점 주소 표시(역지오코딩), 주소·장소 검색, 내 위치(📍).

> OSM 탭은 **키 없이 바로 동작**합니다. 나머지는 각 사의 키를 넣어야 합니다.

---

## 1. 키 발급 (각 지도별)

`index.html` 상단 `window.MAP_KEYS` 에 발급받은 키를 채워 넣으세요.

```js
window.MAP_KEYS = {
  NAVER:  "여기에_네이버_키",
  KAKAO:  "여기에_카카오_JavaScript_키",
  GOOGLE: "여기에_구글_Maps_JS_API_키",
  VWORLD: "여기에_VWorld_인증키"
};
```

| 지도 | 발급처 | 등록 메뉴 | 도메인 등록 |
|---|---|---|---|
| **Naver** | [console.ncloud.com](https://www.ncloud.com) → AI·Application Service → Maps | Application 등록 → Web Dynamic Map | 서비스 URL(예: `https://map.pages.dev`) 등록 필수 |
| **Kakao** | [developers.kakao.com](https://developers.kakao.com) | 내 애플리케이션 → 앱 키 → **JavaScript 키** | 플랫폼 → Web → 사이트 도메인 등록 필수 |
| **Google** | [console.cloud.google.com](https://console.cloud.google.com) | API 및 서비스 → **Maps JavaScript API** 사용 설정 → 사용자 인증 정보(API 키) | HTTP 리퍼러 제한 권장 |
| **VWorld** | [vworld.kr](https://www.vworld.kr) → 오픈API → 인증키 발급 | 2D 지도 / WMTS 용 인증키 | 사용 도메인(URL) 등록 필수 |

> **중요:** Naver·Kakao·VWorld 는 *허용 도메인*에 배포 주소를 등록하지 않으면 지도가 안 뜹니다.
> 로컬 테스트 시 `http://localhost`(또는 `127.0.0.1`)도 등록해 두세요.
> 네이버는 콘솔 버전에 따라 스크립트 파라미터가 `ncpKeyId`(신규) 또는 `ncpClientId`(구버전)입니다.
> 이 앱은 신규 `ncpKeyId` 기준입니다. 구버전 키라면 `index.html`의 `initNaver` 안 `ncpKeyId=` 를 `ncpClientId=` 로 바꾸세요.

---

## 2. 로컬에서 보기

브라우저로 `index.html` 을 직접 열어도 OSM 탭은 동작합니다.
다른 지도 키 도메인 제한 때문에 간단한 로컬 서버 사용을 권장합니다.

```bash
# 둘 중 아무거나
python3 -m http.server 8000
npx serve .
```
→ `http://localhost:8000`

---

## 3. GitHub에 올리기 (빈 레포 hwkim3330/map)

```bash
git init
git add index.html README.md
git commit -m "click to GPS app"
git branch -M main
git remote add origin https://github.com/hwkim3330/map.git
git push -u origin main
```

---

## 4. Cloudflare Pages 배포

1. [dash.cloudflare.com](https://dash.cloudflare.com) → **Workers & Pages** → **Create** → **Pages** → **Connect to Git**
2. GitHub 연동 후 `hwkim3330/map` 선택
3. 빌드 설정:
   - **Framework preset:** None
   - **Build command:** (비움)
   - **Build output directory:** `/`  (루트. index.html이 루트에 있으므로)
4. **Save and Deploy** → 잠시 후 `https://map-xxxx.pages.dev` 주소 생성
5. 생성된 `*.pages.dev` 주소를 **Naver / Kakao / VWorld 콘솔의 허용 도메인**에 등록 (안 하면 해당 탭 지도가 안 뜸)

이후 GitHub에 push 할 때마다 자동 재배포됩니다.

> 커스텀 도메인을 쓰면 Pages 설정 → Custom domains 에서 연결하고, 그 도메인도 각 지도 콘솔에 등록하세요.

---

## 좌표계 참고
- 표시 좌표는 모두 **WGS84 위경도(EPSG:4326)** — GPS/구글맵과 동일 기준입니다.
- 카카오·네이버 내부 좌표도 위경도로 받아 변환 없이 그대로 표시합니다.
- 역지오코딩/검색은 무료 OSM Nominatim을 쓰며 과도한 호출은 제한될 수 있습니다.
