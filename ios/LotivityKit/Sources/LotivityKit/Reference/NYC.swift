import Foundation

/// Real NYC neighborhood centers so radius changes behave plausibly.
/// Venue names in the fixtures are fictional (PRD §9.5).
public struct Neighborhood: Identifiable, Hashable, Sendable {
    public enum Borough: String, Sendable {
        case manhattan = "Manhattan"
        case brooklyn = "Brooklyn"
        case queens = "Queens"
        case bronx = "Bronx"
    }

    public let id: String
    public let name: String
    public let borough: Borough
    public let center: GeoPoint
}

public let neighborhoods: [Neighborhood] = [
    Neighborhood(id: "les", name: "Lower East Side", borough: .manhattan, center: GeoPoint(lat: 40.715, lng: -73.9857)),
    Neighborhood(id: "ev", name: "East Village", borough: .manhattan, center: GeoPoint(lat: 40.7265, lng: -73.9815)),
    Neighborhood(id: "wv", name: "West Village", borough: .manhattan, center: GeoPoint(lat: 40.7358, lng: -74.0036)),
    Neighborhood(id: "chelsea", name: "Chelsea", borough: .manhattan, center: GeoPoint(lat: 40.7465, lng: -74.0014)),
    Neighborhood(id: "hk", name: "Hell's Kitchen", borough: .manhattan, center: GeoPoint(lat: 40.7638, lng: -73.9918)),
    Neighborhood(id: "uws", name: "Upper West Side", borough: .manhattan, center: GeoPoint(lat: 40.787, lng: -73.9754)),
    Neighborhood(id: "ues", name: "Upper East Side", borough: .manhattan, center: GeoPoint(lat: 40.7736, lng: -73.9566)),
    Neighborhood(id: "harlem", name: "Harlem", borough: .manhattan, center: GeoPoint(lat: 40.8116, lng: -73.9465)),
    Neighborhood(id: "wash-heights", name: "Washington Heights", borough: .manhattan, center: GeoPoint(lat: 40.8417, lng: -73.9394)),
    Neighborhood(id: "inwood", name: "Inwood", borough: .manhattan, center: GeoPoint(lat: 40.8677, lng: -73.9212)),
    Neighborhood(id: "wburg", name: "Williamsburg", borough: .brooklyn, center: GeoPoint(lat: 40.7143, lng: -73.9613)),
    Neighborhood(id: "bushwick", name: "Bushwick", borough: .brooklyn, center: GeoPoint(lat: 40.6944, lng: -73.9213)),
    Neighborhood(id: "bedstuy", name: "Bedford-Stuyvesant", borough: .brooklyn, center: GeoPoint(lat: 40.6872, lng: -73.9418)),
    Neighborhood(id: "ftgreene", name: "Fort Greene", borough: .brooklyn, center: GeoPoint(lat: 40.6892, lng: -73.9742)),
    Neighborhood(id: "parkslope", name: "Park Slope", borough: .brooklyn, center: GeoPoint(lat: 40.6710, lng: -73.9814)),
    Neighborhood(id: "crownhts", name: "Crown Heights", borough: .brooklyn, center: GeoPoint(lat: 40.6694, lng: -73.9442)),
    Neighborhood(id: "sunsetpark", name: "Sunset Park", borough: .brooklyn, center: GeoPoint(lat: 40.6454, lng: -74.0122)),
    Neighborhood(id: "flatbush", name: "Flatbush", borough: .brooklyn, center: GeoPoint(lat: 40.6409, lng: -73.9624)),
    Neighborhood(id: "astoria", name: "Astoria", borough: .queens, center: GeoPoint(lat: 40.7644, lng: -73.9235)),
    Neighborhood(id: "lic", name: "Long Island City", borough: .queens, center: GeoPoint(lat: 40.7447, lng: -73.9485)),
    Neighborhood(id: "jacksonhts", name: "Jackson Heights", borough: .queens, center: GeoPoint(lat: 40.7557, lng: -73.8831)),
    Neighborhood(id: "flushing", name: "Flushing", borough: .queens, center: GeoPoint(lat: 40.7674, lng: -73.833)),
    Neighborhood(id: "jamaica", name: "Jamaica", borough: .queens, center: GeoPoint(lat: 40.7027, lng: -73.7889)),
    Neighborhood(id: "sunnyside", name: "Sunnyside", borough: .queens, center: GeoPoint(lat: 40.7433, lng: -73.9196)),
    Neighborhood(id: "mott-haven", name: "Mott Haven", borough: .bronx, center: GeoPoint(lat: 40.809, lng: -73.9229)),
    Neighborhood(id: "fordham", name: "Fordham", borough: .bronx, center: GeoPoint(lat: 40.8618, lng: -73.8905)),
]

public let neighborhoodByID: [String: Neighborhood] = Dictionary(
    uniqueKeysWithValues: neighborhoods.map { ($0.id, $0) }
)

/// Fallback center when location is denied or unavailable (FR-MAP-6).
public let defaultCenter = GeoPoint(lat: 40.7295, lng: -73.9665)
public let defaultCenterLabel = "East Village, Manhattan"

/// Rough bounds used to decide whether a real location fix is usable.
public enum NYCBounds {
    public static let minLat = 40.47
    public static let maxLat = 40.93
    public static let minLng = -74.27
    public static let maxLng = -73.68
}

public func isWithinNYC(_ p: GeoPoint) -> Bool {
    p.lat >= NYCBounds.minLat && p.lat <= NYCBounds.maxLat
        && p.lng >= NYCBounds.minLng && p.lng <= NYCBounds.maxLng
}
