import CoreLocation
import LotivityKit
import Observation

/// One-shot location with a stated reason; denial is a soft landing (FR-MAP-6).
@Observable
@MainActor
final class LocationProvider: NSObject, CLLocationManagerDelegate {
    enum Outcome: Equatable {
        case idle
        case fixed(GeoPoint)
        /// Denied, unavailable, or a fix outside the fixture world's city.
        case unavailable
    }

    private(set) var outcome: Outcome = .idle
    private let manager = CLLocationManager()

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyHundredMeters
    }

    func request() {
        switch manager.authorizationStatus {
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        case .denied, .restricted:
            outcome = .unavailable
        default:
            manager.requestLocation()
        }
    }

    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let status = manager.authorizationStatus
        Task { @MainActor in
            switch status {
            case .authorizedWhenInUse, .authorizedAlways:
                manager.requestLocation()
            case .denied, .restricted:
                outcome = .unavailable
            default:
                break
            }
        }
    }

    nonisolated func locationManager(
        _ manager: CLLocationManager,
        didUpdateLocations locations: [CLLocation]
    ) {
        guard let coordinate = locations.last?.coordinate else { return }
        let point = GeoPoint(lat: coordinate.latitude, lng: coordinate.longitude)
        Task { @MainActor in
            // The fixture world is NYC-only; a real fix elsewhere would show an
            // empty map, which reads as broken rather than as "you're not in NYC".
            outcome = isWithinNYC(point) ? .fixed(point) : .unavailable
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        Task { @MainActor in outcome = .unavailable }
    }
}
