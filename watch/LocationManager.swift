import Foundation
import CoreLocation
import Combine

/// 현재 위치(WGS84)와 역지오코딩 주소를 발행하는 관찰 객체.
/// CoreLocation 과 CLGeocoder 는 watchOS 에서도 동작합니다.
final class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var coordinate: CLLocationCoordinate2D?
    @Published var address: String = ""
    @Published var accuracy: CLLocationAccuracy = -1
    @Published var authorized: Bool = false

    private let manager = CLLocationManager()
    private let geocoder = CLGeocoder()
    private var lastGeocode = Date(timeIntervalSince1970: 0)

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
    }

    func start() {
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
    }

    func refresh() {
        manager.requestLocation()
    }

    // MARK: - CLLocationManagerDelegate
    func locationManagerDidChangeAuthorization(_ m: CLLocationManager) {
        let s = m.authorizationStatus
        authorized = (s == .authorizedWhenInUse || s == .authorizedAlways)
        if authorized { m.startUpdatingLocation() }
    }

    func locationManager(_ m: CLLocationManager, didUpdateLocations locs: [CLLocation]) {
        guard let loc = locs.last else { return }
        coordinate = loc.coordinate
        accuracy = loc.horizontalAccuracy
        reverseGeocode(loc)
    }

    func locationManager(_ m: CLLocationManager, didFailWithError error: Error) {
        // 무시(다음 업데이트 대기)
    }

    private func reverseGeocode(_ loc: CLLocation) {
        // 과도한 호출 방지: 3초에 한 번
        guard Date().timeIntervalSince(lastGeocode) > 3 else { return }
        lastGeocode = Date()
        let ko = Locale(identifier: "ko_KR")
        geocoder.reverseGeocodeLocation(loc, preferredLocale: ko) { [weak self] places, _ in
            guard let p = places?.first else { return }
            let parts = [p.administrativeArea, p.locality, p.subLocality, p.thoroughfare, p.subThoroughfare]
                .compactMap { $0 }
            DispatchQueue.main.async { self?.address = parts.joined(separator: " ") }
        }
    }
}
