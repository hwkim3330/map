import SwiftUI
import WatchConnectivity
import UIKit

// 아이폰 컴패니언 앱(선택).
// 워치가 보낸 좌표를 받아 아이폰 클립보드에 복사하고 화면에 표시합니다.
// 워치 앱만으로도 좌표 확인은 되지만, "복사"는 아이폰 클립보드가 필요해서 이 앱이 처리합니다.

@main
struct PhoneApp: App {
    @StateObject private var bridge = PhoneReceiver()
    var body: some Scene {
        WindowGroup {
            VStack(spacing: 16) {
                Text("워치에서 받은 좌표").font(.headline)
                Text(bridge.lastCoord.isEmpty ? "—" : bridge.lastCoord)
                    .font(.system(.title3, design: .monospaced))
                    .textSelection(.enabled)
                if !bridge.lastCoord.isEmpty {
                    Text("클립보드에 복사됨 ✓").font(.caption).foregroundColor(.green)
                    Button("다시 복사") { UIPasteboard.general.string = bridge.lastCoord }
                        .buttonStyle(.borderedProminent)
                }
            }
            .padding()
        }
    }
}

final class PhoneReceiver: NSObject, ObservableObject, WCSessionDelegate {
    @Published var lastCoord: String = ""

    override init() {
        super.init()
        if WCSession.isSupported() {
            WCSession.default.delegate = self
            WCSession.default.activate()
        }
    }

    private func handle(_ dict: [String: Any]) {
        guard let c = dict["coord"] as? String else { return }
        DispatchQueue.main.async {
            self.lastCoord = c
            UIPasteboard.general.string = c   // 자동 클립보드 복사
        }
    }

    func session(_ s: WCSession, didReceiveMessage message: [String: Any]) { handle(message) }
    func session(_ s: WCSession, didReceiveApplicationContext ctx: [String: Any]) { handle(ctx) }

    // 필수 스텁
    func session(_ s: WCSession, activationDidCompleteWith state: WCSessionActivationState, error: Error?) {}
    func sessionDidBecomeInactive(_ s: WCSession) {}
    func sessionDidDeactivate(_ s: WCSession) { WCSession.default.activate() }
}
