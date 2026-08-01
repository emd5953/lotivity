import Foundation

private let earthRadiusMiles = 3958.8
private func toRad(_ deg: Double) -> Double { deg * .pi / 180 }

/// Great-circle distance in miles. Kept pure so the same semantics can move to
/// PostGIS without behavior change (BR-4).
public func distanceMiles(_ a: GeoPoint, _ b: GeoPoint) -> Double {
    let dLat = toRad(b.lat - a.lat)
    let dLng = toRad(b.lng - a.lng)
    let lat1 = toRad(a.lat)
    let lat2 = toRad(b.lat)

    let h = pow(sin(dLat / 2), 2) + pow(sin(dLng / 2), 2) * cos(lat1) * cos(lat2)
    return 2 * earthRadiusMiles * asin(min(1, sqrt(h)))
}

public func withinRadius(_ center: GeoPoint, _ point: GeoPoint, radiusMi: Double) -> Bool {
    distanceMiles(center, point) <= radiusMi
}

public func filterByRadius<T>(
    _ items: [T],
    center: GeoPoint,
    radiusMi: Double,
    locate: (T) -> GeoPoint
) -> [T] {
    items.filter { withinRadius(center, locate($0), radiusMi: radiusMi) }
}

/// 1 at the center, 0 at the radius edge, clamped. Used by the recommendation
/// engine's proximity term (TRD §6).
public func proximityScore(_ center: GeoPoint, _ point: GeoPoint, radiusMi: Double) -> Double {
    guard radiusMi > 0 else { return 0 }
    let d = distanceMiles(center, point)
    return max(0, min(1, 1 - d / radiusMi))
}

public func formatDistance(_ miles: Double) -> String {
    if miles < 0.1 { return "right here" }
    if miles < 0.5 { return "\(Int((miles * 5280 / 100).rounded()) * 100) ft away" }
    return String(format: "%.1f mi away", miles)
}

/// Square bounds around a center, sized to hold the radius.
public func boundsForRadius(_ center: GeoPoint, radiusMi: Double) -> (sw: GeoPoint, ne: GeoPoint) {
    let latDelta = radiusMi / 69
    let lngDelta = radiusMi / (69 * max(0.1, cos(toRad(center.lat))))
    return (
        GeoPoint(lat: center.lat - latDelta, lng: center.lng - lngDelta),
        GeoPoint(lat: center.lat + latDelta, lng: center.lng + lngDelta)
    )
}

/// Deterministic offset used by fixtures to scatter points inside a neighborhood.
public func offsetPoint(_ origin: GeoPoint, miNorth: Double, miEast: Double) -> GeoPoint {
    GeoPoint(
        lat: origin.lat + miNorth / 69,
        lng: origin.lng + miEast / (69 * max(0.1, cos(toRad(origin.lat))))
    )
}
