import Foundation
import WatchConnectivity

/// 워치 → 아이폰 으로 좌표 문자열을 전송합니다.
/// 아이폰 컴패니언 앱(PhoneApp.swift)이 이를 받아 클립보드에 복사합니다.
/// 컴패니언 앱이 없어도 크래시 없이 무시됩니다.
final class PhoneBridge: NSObject, WCSessionDelegate {
    static let shared = PhoneBridge()

    override init() {
        super.init()
        if WCSession.isSupported() {
            WCSession.default.delegate = self
            WCSession.default.activate()
        }
    }

    func send(coord: String) {
        guard WCSession.isSupported() else { return }
        let s = WCSession.default
        let payload = ["coord": coord]
        if s.isReachable {
            s.sendMessage(payload, replyHandler: nil, errorHandler: nil)
        } else {
            // 아이폰이 안 깨어있어도 다음 동기화 때 전달
            try? s.updateApplicationContext(payload)
        }
    }

    // MARK: WCSessionDelegate (필수 스텁)
    func session(_ s: WCSession, activationDidCompleteWith state: WCSessionActivationState, error: Error?) {}
}
