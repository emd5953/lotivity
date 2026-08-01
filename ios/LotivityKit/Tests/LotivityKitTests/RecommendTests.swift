import XCTest
@testable import LotivityKit

private let center = GeoPoint(lat: 40.7265, lng: -73.9815)

private let baseUser = ScoreContext.Subject(
    id: "user:me",
    interests: ["interest:running", "interest:music"],
    heritage: ["heritage:colombia"],
    cultureTags: ["faith:christian", "community:latin"],
    generation: .millennial,
    location: center
)

private func baseCtx(
    networkIds: [ID] = [],
    seenEventIds: [ID] = [],
    suppressFactors: Set<FactorID> = [],
    interestLabel: @escaping @Sendable (ID) -> String = { $0 }
) -> ScoreContext {
    ScoreContext(
        user: baseUser,
        now: Date(timeIntervalSince1970: 1_785_240_000),
        radiusMi: 5,
        networkIds: networkIds,
        seenEventIds: seenEventIds,
        suppressFactors: suppressFactors,
        interestLabel: interestLabel
    )
}

private func makeEvent(
    id: ID = "event:1",
    location: GeoPoint = GeoPoint(lat: 40.8618, lng: -73.8905), // far: proximity ≈ 0
    interestTags: [ID] = [],
    heritageTags: [ID] = [],
    cultureTags: [ID] = [],
    generationTags: [Generation] = [],
    attendeeIds: [ID] = []
) -> LotivityEvent {
    LotivityEvent(
        id: id,
        title: "Test event",
        hostId: "user:1",
        hostType: .user,
        category: .social,
        location: location,
        neighborhood: "Fordham",
        startsAt: Date(timeIntervalSince1970: 1_785_412_800),
        endsAt: Date(timeIntervalSince1970: 1_785_420_000),
        interestTags: interestTags,
        heritageTags: heritageTags,
        cultureTags: cultureTags,
        generationTags: generationTags,
        attendeeIds: attendeeIds,
        interestedIds: [],
        requiresGuardian: false
    )
}

final class RecommendFactorTests: XCTestCase {
    func testScoresNothingWhenNothingMatches() {
        XCTAssertEqual(scoreEvent(makeEvent(), baseCtx()).score, 0)
    }

    func testWeightsPartialInterestOverlapProportionally() {
        // One of the user's two interests matches → 0.5 × 3.0
        let score = scoreEvent(makeEvent(interestTags: ["interest:running"]), baseCtx()).score
        XCTAssertEqual(score, 0.5 * Weights[.interestOverlap], accuracy: 1e-5)
    }

    func testAppliesHeritageMatchAsAFlatTerm() {
        let score = scoreEvent(makeEvent(heritageTags: ["heritage:colombia"]), baseCtx()).score
        XCTAssertEqual(score, Weights[.heritageMatch], accuracy: 1e-5)
    }

    func testAppliesCultureMatchAsAFlatTerm() {
        let score = scoreEvent(makeEvent(cultureTags: ["faith:christian"]), baseCtx()).score
        XCTAssertEqual(score, Weights[.cultureMatch], accuracy: 1e-5)
    }

    func testAppliesGenerationMatchAsAFlatTerm() {
        let score = scoreEvent(makeEvent(generationTags: [.millennial]), baseCtx()).score
        XCTAssertEqual(score, Weights[.generationMatch], accuracy: 1e-5)
    }

    func testGivesFullProximityCreditAtTheUserLocation() {
        let score = scoreEvent(makeEvent(location: center), baseCtx()).score
        XCTAssertEqual(score, Weights[.proximity], accuracy: 1e-5)
    }

    func testScalesNetworkAttendanceByTheShareOfTheNetworkGoing() {
        let score = scoreEvent(
            makeEvent(attendeeIds: ["user:a", "user:b"]),
            baseCtx(networkIds: ["user:a", "user:b", "user:c", "user:d"])
        ).score
        XCTAssertEqual(score, 0.5 * Weights[.networkAttendance], accuracy: 1e-5)
    }

    func testSubtractsTheRecencyPenaltyForAnEventAlreadyShown() {
        let score = scoreEvent(
            makeEvent(generationTags: [.millennial]),
            baseCtx(seenEventIds: ["event:1"])
        ).score
        XCTAssertEqual(score, Weights[.generationMatch] - Weights[.recencyPenalty], accuracy: 1e-5)
    }
}

final class RecommendReasonTests: XCTestCase {
    func testReturnsTheTwoStrongestPositiveFactorsStrongestFirst() {
        let top = scoreEvent(
            makeEvent(
                location: center,
                interestTags: ["interest:running", "interest:music"],
                generationTags: [.millennial]
            ),
            baseCtx()
        ).topFactors

        // interest (1.0 × 3.0) then proximity (1.0 × 2.0), ahead of generation (1.0).
        XCTAssertEqual(top.count, 2)
        XCTAssertEqual(top[0].id, .interestOverlap)
        XCTAssertEqual(top[1].id, .proximity)
    }

    func testNamesTheMatchedInterestInTheReason() {
        let top = scoreEvent(
            makeEvent(interestTags: ["interest:running"]),
            baseCtx(interestLabel: { _ in "Running" })
        ).topFactors
        XCTAssertEqual(top.first?.reason, "Because you follow Running")
    }

    func testNamesTheEventsPrimarySubjectNotTheUsersFirstListedInterest() {
        // User lists Running before Music, but this is a music event that happens
        // to also carry a running tag. Explaining it as Running reads as a bug.
        let top = scoreEvent(
            makeEvent(interestTags: ["interest:music", "interest:running"]),
            baseCtx(interestLabel: { $0 == "interest:music" ? "Music" : "Running" })
        ).topFactors
        XCTAssertEqual(top.first?.reason, "Because you follow Music")
    }

    func testOmitsSuppressedFactorsFromBothTheScoreAndTheReasons() {
        // Guest mode: no network, no declared generation.
        let scored = scoreEvent(
            makeEvent(location: center, generationTags: [.millennial], attendeeIds: ["user:a"]),
            baseCtx(
                networkIds: ["user:a"],
                suppressFactors: [.generationMatch, .networkAttendance]
            )
        )
        XCTAssertEqual(scored.factors.map(\.id), [.proximity])
        XCTAssertEqual(scored.score, Weights[.proximity], accuracy: 1e-5)
    }

    func testNeverSurfacesTheRecencyPenaltyAsAReason() {
        let top = scoreEvent(
            makeEvent(generationTags: [.millennial]),
            baseCtx(seenEventIds: ["event:1"])
        ).topFactors
        XCTAssertTrue(top.allSatisfy { $0.id != .recencyPenalty })
    }
}

final class RankEventsTests: XCTestCase {
    private let strong = makeEvent(
        id: "event:strong",
        location: center,
        interestTags: ["interest:running", "interest:music"],
        heritageTags: ["heritage:colombia"]
    )
    private let weak = makeEvent(id: "event:weak")

    func testOrdersByDescendingScore() {
        let ranked = rankEvents([weak, strong], baseCtx())
        XCTAssertEqual(ranked.map(\.event.id), ["event:strong", "event:weak"])
    }

    func testIsDeterministic() {
        let a = rankEvents([weak, strong], baseCtx()).map(\.event.id)
        let b = rankEvents([weak, strong], baseCtx()).map(\.event.id)
        XCTAssertEqual(a, b)
    }

    func testBreaksTiesStablyByIDRatherThanInputOrder() {
        let tieA = makeEvent(id: "event:aaa")
        let tieB = makeEvent(id: "event:bbb")
        XCTAssertEqual(
            rankEvents([tieB, tieA], baseCtx()).map(\.event.id),
            ["event:aaa", "event:bbb"]
        )
    }
}
