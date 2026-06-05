/**
 * Kakao REST 프록시 (Cloudflare Worker)
 * --------------------------------------
 * 카카오 REST 키는 "서버에서만" 써야 안전합니다. 이 Worker 가 키를 숨긴 채
 * 카카오 로컬 API(주소/키워드 검색, 좌표→주소)를 대신 호출해 줍니다.
 *
 * 배포:
 *   1) https://developers.kakao.com → 내 애플리케이션 → 앱 키 → "REST API 키" 복사
 *   2) npm i -g wrangler && wrangler login
 *   3) cd worker && wrangler secret put KAKAO_REST_KEY   (복사한 REST 키 붙여넣기)
 *   4) wrangler deploy
 *   5) 출력된 https://kakao-proxy.<you>.workers.dev 를 index.html MAP_KEYS.PROXY 또는
 *      GitHub Secret PROXY_URL 에 넣기
 *
 * 보안:
 *   - ALLOW_ORIGINS 환경변수(콤마구분)로 허용 도메인을 제한하세요. 비우면 모두 허용(테스트용).
 *   - REST 키는 wrangler secret 로만 보관 → 코드/깃에 노출 안 됨.
 *
 * 엔드포인트:
 *   GET /search?q=강남역            → 키워드+주소 통합 검색 (documents[].x=lng, y=lat)
 *   GET /coord2address?x=&y=        → 좌표(WGS84)→주소
 */

const KAKAO = "https://dapi.kakao.com";

export default {
  async fetch(request, env) {
    const url = new URL(request.url);
    const origin = request.headers.get("Origin") || "";
    const cors = corsHeaders(origin, env);

    if (request.method === "OPTIONS") return new Response(null, { status: 204, headers: cors });
    if (!originAllowed(origin, env)) return json({ error: "origin not allowed" }, 403, cors);

    const auth = { Authorization: `KakaoAK ${env.KAKAO_REST_KEY}` };

    try {
      if (url.pathname === "/search") {
        const q = url.searchParams.get("q");
        if (!q) return json({ error: "missing q" }, 400, cors);
        // 1) 주소 검색 우선 (정확). 결과 없으면 2) 키워드 검색.
        let r = await fetch(`${KAKAO}/v2/local/search/address.json?query=${encodeURIComponent(q)}`, { headers: auth });
        let d = await r.json();
        if (!d.documents || !d.documents.length) {
          r = await fetch(`${KAKAO}/v2/local/search/keyword.json?query=${encodeURIComponent(q)}`, { headers: auth });
          d = await r.json();
        }
        return json(d, 200, cors);
      }

      if (url.pathname === "/coord2address") {
        const x = url.searchParams.get("x"), y = url.searchParams.get("y"); // x=lng, y=lat
        if (!x || !y) return json({ error: "missing x/y" }, 400, cors);
        const r = await fetch(`${KAKAO}/v2/local/geo/coord2address.json?x=${x}&y=${y}`, { headers: auth });
        return json(await r.json(), 200, cors);
      }

      return json({ error: "not found", routes: ["/search?q=", "/coord2address?x=&y="] }, 404, cors);
    } catch (e) {
      return json({ error: String(e) }, 502, cors);
    }
  }
};

function originAllowed(origin, env) {
  const allow = (env.ALLOW_ORIGINS || "").split(",").map(s => s.trim()).filter(Boolean);
  if (!allow.length) return true;            // 미설정 시 전체 허용(테스트)
  return allow.includes(origin);
}
function corsHeaders(origin, env) {
  const allow = (env.ALLOW_ORIGINS || "").split(",").map(s => s.trim()).filter(Boolean);
  const ao = (!allow.length || allow.includes(origin)) ? (origin || "*") : "null";
  return {
    "Access-Control-Allow-Origin": ao,
    "Access-Control-Allow-Methods": "GET,OPTIONS",
    "Access-Control-Allow-Headers": "Content-Type",
    "Vary": "Origin",
  };
}
function json(obj, status, cors) {
  return new Response(JSON.stringify(obj), { status, headers: { "Content-Type": "application/json; charset=utf-8", ...cors } });
}
