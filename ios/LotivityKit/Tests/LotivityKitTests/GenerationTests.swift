import XCTest
@testable import LotivityKit

final class GenerationTests: XCTestCase {
    func testMapsEachCohortAtItsBoundaries() {
        // Boundary years are where an off-by-one would hide.
        XCTAssertEqual(generationFromDob("1945-12-31"), .silent)
        XCTAssertEqual(generationFromDob("1946-01-01"), .boomer)
        XCTAssertEqual(generationFromDob("1964-12-31"), .boomer)
        XCTAssertEqual(generationFromDob("1965-01-01"), .genx)
        XCTAssertEqual(generationFromDob("1980-12-31"), .genx)
        XCTAssertEqual(generationFromDob("1981-01-01"), .millennial)
        XCTAssertEqual(generationFromDob("1996-12-31"), .millennial)
        XCTAssertEqual(generationFromDob("1997-01-01"), .genz)
        XCTAssertEqual(generationFromDob("2012-12-31"), .genz)
        XCTAssertEqual(generationFromDob("2013-01-01"), .alpha)
    }

    func testTreatsAnyoneOlderThanTheSilentGenerationAsTheOldestCohort() {
        XCTAssertEqual(generationFromDob("1910-05-05"), .silent)
    }

    func testFallsBackRatherThanThrowingOnUnparseableInput() {
        XCTAssertEqual(generationFromDob(""), .millennial)
        XCTAssertEqual(generationFromDob("not-a-date"), .millennial)
    }

    /// The web version derives the year from a `Date`, which shifts the answer
    /// by a year in time zones ahead of UTC. Reading the string as calendar
    /// components is what makes this hold everywhere.
    func testIsIndependentOfTheDeviceTimeZone() {
        XCTAssertEqual(birthYear(from: "1946-01-01"), 1946)
        XCTAssertNil(birthYear(from: "1946-01"))
    }
}

final class AgeTests: XCTestCase {
    private let now = Date(timeIntervalSince1970: 1_785_240_000) // 2026-07-28T12:00:00Z

    func testDoesNotCountABirthdayThatHasNotHappenedYetThisYear() {
        XCTAssertEqual(ageFromDob("2000-07-29", now: now), 25)
        XCTAssertEqual(ageFromDob("2000-07-28", now: now), 26)
    }

    func testSuggestAccountTypeRoutesByAgeBand() {
        XCTAssertEqual(suggestAccountType("2012-01-01", now: now), .youth)
        XCTAssertEqual(suggestAccountType("1995-01-01", now: now), .adult)
        XCTAssertEqual(suggestAccountType("1950-01-01", now: now), .retired)
    }
}
