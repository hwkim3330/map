import SwiftUI
import CoreLocation

struct ContentView: View {
    @StateObject private var loc = LocationManager()

    private var latText: String { loc.coordinate.map { String(format: "%.6f", $0.latitude) } ?? "—" }
    private var lngText: String { loc.coordinate.map { String(format: "%.6f", $0.longitude) } ?? "—" }
    private var coordLine: String {
        guard let c = loc.coordinate else { return "" }
        return String(format: "%.6f, %.6f", c.latitude, c.longitude)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 8) {
                Text("내 위치 (WGS84)")
                    .font(.caption2).foregroundColor(.secondary)

                VStack(alignment: .leading, spacing: 2) {
                    Text("위도 \(latText)").font(.system(.body, design: .rounded)).monospacedDigit()
                    Text("경도 \(lngText)").font(.system(.body, design: .rounded)).monospacedDigit()
                }

                if loc.accuracy > 0 {
                    Text(String(format: "정확도 ±%.0f m", loc.accuracy))
                        .font(.caption2).foregroundColor(.secondary)
                }
                if !loc.address.isEmpty {
                    Text("📍 \(loc.address)").font(.caption2).foregroundColor(.secondary)
                }

                Button {
                    loc.refresh()
                } label: {
                    Label("새로고침", systemImage: "location.fill")
                }
                .buttonStyle(.borderedProminent)

                // 워치에는 시스템 클립보드가 없습니다 → 페어링된 아이폰으로 좌표를 보내
                // 아이폰 앱이 클립보드에 복사합니다(아래 iOS 컴패니언 참고).
                Button {
                    if !coordLine.isEmpty { PhoneBridge.shared.send(coord: coordLine) }
                } label: {
                    Label("아이폰으로 복사", systemImage: "iphone")
                }
                .buttonStyle(.bordered)
                .disabled(loc.coordinate == nil)

                if !loc.authorized {
                    Text("위치 권한을 허용해 주세요").font(.caption2).foregroundColor(.orange)
                }
            }
            .padding(.horizontal, 4)
        }
        .onAppear { loc.start() }
    }
}

#Preview {
    ContentView()
}
