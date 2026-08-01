import XCTest
@testable import LotivityKit

private let eastVillage = GeoPoint(lat: 40.7265, lng: -73.9815)
private let williamsburg = GeoPoint(lat: 40.7143, lng: -73.9613)
private let fordham = GeoPoint(lat: 40.8618, lng: -73.8905)

final class GeoTests: XCTestCase {
    func testDistanceIsZeroForTheSamePoint() {
        XCTAssertEqual(distanceMiles(eastVillage, eastVillage), 0)
    }

    func testMeasuresAKnownShortHopAcrossTheEastRiver() {
        // East Village → Williamsburg is a little over 1.35 mi as the crow flies.
        XCTAssertEqual(distanceMiles(eastVillage, williamsburg), 1.35, accuracy: 0.005)
    }

    func testDistanceIsSymmetric() {
        XCTAssertEqual(
            distanceMiles(eastVillage, fordham),
            distanceMiles(fordham, eastVillage),
            accuracy: 1e-6
        )
    }

    func testWithinRadiusIncludesTheBoundaryAndExcludesPastIt() {
        let d = distanceMiles(eastVillage, williamsburg)
        XCTAssertTrue(withinRadius(eastVillage, williamsburg, radiusMi: d))
        XCTAssertFalse(withinRadius(eastVillage, williamsburg, radiusMi: d - 0.01))
    }

    func testProximityIsOneAtTheCenterAndZeroAtTheEdge() {
        XCTAssertEqual(proximityScore(eastVillage, eastVillage, radiusMi: 5), 1)
        let d = distanceMiles(eastVillage, williamsburg)
        XCTAssertEqual(proximityScore(eastVillage, williamsburg, radiusMi: d), 0, accuracy: 1e-5)
    }

    func testProximityClampsToZeroBeyondTheRadius() {
        XCTAssertEqual(proximityScore(eastVillage, fordham, radiusMi: 1), 0)
    }

    func testProximityIsZeroForAZeroRadiusInsteadOfDividingByZero() {
        XCTAssertEqual(proximityScore(eastVillage, williamsburg, radiusMi: 0), 0)
    }

    func testFilterByRadiusKeepsOnlyItemsInside() {
        let items = [(id: "near", at: williamsburg), (id: "far", at: fordham)]
        let kept = filterByRadius(items, center: eastVillage, radiusMi: 3) { $0.at }
        XCTAssertEqual(kept.map(\.id), ["near"])
    }

    func testFormatDistanceSwitchesUnitsCloseIn() {
        XCTAssertEqual(formatDistance(0.05), "right here")
        XCTAssertEqual(formatDistance(0.2), "1100 ft away")
        XCTAssertEqual(formatDistance(1.349), "1.3 mi away")
    }
}
