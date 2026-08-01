import Foundation

/// Single source of tuning (FR-REC-3). Mirrors docs/TECHNICAL_REQUIREMENTS.md §6.
/// Changing ranking behavior should never require touching a call site.
public enum FactorID: String, CaseIterable, Sendable {
    case interestOverlap
    case heritageMatch
    case cultureMatch
    case generationMatch
    case proximity
    case networkAttendance
    case recencyPenalty
}

public enum Weights {
    public static let values: [FactorID: Double] = [
        .interestOverlap: 3.0,
        .heritageMatch: 2.0,
        .cultureMatch: 1.5,
        .generationMatch: 1.0,
        .proximity: 2.0,
        .networkAttendance: 1.0,
        .recencyPenalty: 2.0,
    ]

    public static subscript(_ id: FactorID) -> Double { values[id] ?? 0 }
}

/// Feed ranking assumes this radius when the user has not set one.
public let defaultFeedRadiusMi: Double = 5

public struct Factor: Hashable, Sendable, Identifiable {
    public let id: FactorID
    /// Raw 0..1 strength before weighting.
    public let value: Double
    /// Weighted contribution to the total score.
    public let contribution: Double
    /// Human-readable clause for "why you're seeing this" (FR-FEED-3).
    public let reason: String
}

public struct ScoredEvent: Identifiable, Sendable {
    public let event: LotivityEvent
    public let score: Double
    public let factors: [Factor]
    /// Top two positive contributors, strongest first (FR-REC-2).
    public let topFactors: [Factor]
    public let distanceMi: Double

    public var id: ID { event.id }
}

public struct ScoreContext: Sendable {
    /// The slice of a user that ranking is allowed to see.
    public struct Subject: Sendable {
        public var id: ID
        public var interests: [ID]
        public var heritage: [ID]
        public var cultureTags: [ID]
        public var generation: Generation
        public var location: GeoPoint

        public init(
            id: ID,
            interests: [ID],
            heritage: [ID],
            cultureTags: [ID],
            generation: Generation,
            location: GeoPoint
        ) {
            self.id = id
            self.interests = interests
            self.heritage = heritage
            self.cultureTags = cultureTags
            self.generation = generation
            self.location = location
        }

        public init(_ user: User) {
            self.init(
                id: user.id,
                interests: user.interests,
                heritage: user.heritage,
                cultureTags: user.cultureTags,
                generation: user.generation,
                location: user.location
            )
        }
    }

    public var user: Subject
    public var now: Date
    public var radiusMi: Double?
    /// Peer ids used for the network-attendance term.
    public var networkIds: [ID]
    /// Event ids already shown, used for the recency penalty.
    public var seenEventIds: [ID]
    /// Factors to leave out entirely. Guests have no network and no stated
    /// generation, so scoring on either would invent a claim the card then
    /// repeats back to them.
    public var suppressFactors: Set<FactorID>
    public var heritageLabel: @Sendable (ID) -> String
    public var cultureLabel: @Sendable (ID) -> String
    public var interestLabel: @Sendable (ID) -> String

    public init(
        user: Subject,
        now: Date,
        radiusMi: Double? = nil,
        networkIds: [ID] = [],
        seenEventIds: [ID] = [],
        suppressFactors: Set<FactorID> = [],
        heritageLabel: @escaping @Sendable (ID) -> String = { $0 },
        cultureLabel: @escaping @Sendable (ID) -> String = { $0 },
        interestLabel: @escaping @Sendable (ID) -> String = { $0 }
    ) {
        self.user = user
        self.now = now
        self.radiusMi = radiusMi
        self.networkIds = networkIds
        self.seenEventIds = seenEventIds
        self.suppressFactors = suppressFactors
        self.heritageLabel = heritageLabel
        self.cultureLabel = cultureLabel
        self.interestLabel = interestLabel
    }
}

private func overlap(_ a: [ID], _ b: [ID]) -> Double {
    guard !a.isEmpty else { return 0 }
    let set = Set(b)
    return Double(a.filter { set.contains($0) }.count) / Double(a.count)
}

/// Scans in the *event's* tag order, not the user's. An event's first tag is its
/// primary subject, so a reading night explains itself as reading even when the
/// user also happens to follow a secondary tag on it.
private func firstShared(_ userTags: [ID], _ eventTags: [ID]) -> ID? {
    let owned = Set(userTags)
    return eventTags.first { owned.contains($0) }
}

/// Pure and deterministic: same (user, event, now) always yields the same score
/// and the same reasons (FR-REC-1).
public func scoreEvent(_ event: LotivityEvent, _ ctx: ScoreContext) -> ScoredEvent {
    let radiusMi = ctx.radiusMi ?? defaultFeedRadiusMi

    var factors: [Factor] = []
    func add(_ id: FactorID, _ value: Double, _ reason: String) {
        guard value != 0, !ctx.suppressFactors.contains(id) else { return }
        factors.append(
            Factor(id: id, value: value, contribution: value * Weights[id], reason: reason)
        )
    }

    let interestValue = overlap(ctx.user.interests, event.interestTags)
    let sharedInterest = firstShared(ctx.user.interests, event.interestTags)
    add(
        .interestOverlap,
        interestValue,
        sharedInterest.map { "Because you follow \(ctx.interestLabel($0))" } ?? "Matches your interests"
    )

    let sharedHeritage = firstShared(ctx.user.heritage, event.heritageTags)
    add(
        .heritageMatch,
        sharedHeritage != nil ? 1 : 0,
        sharedHeritage.map { "\(ctx.heritageLabel($0)) heritage" } ?? ""
    )

    let sharedCulture = firstShared(ctx.user.cultureTags, event.cultureTags)
    add(
        .cultureMatch,
        sharedCulture != nil ? 1 : 0,
        sharedCulture.map { "For the \(ctx.cultureLabel($0)) community" } ?? ""
    )

    add(
        .generationMatch,
        event.generationTags.contains(ctx.user.generation) ? 1 : 0,
        "Popular with your generation"
    )

    let distanceMi = distanceMiles(ctx.user.location, event.location)
    let proximity = proximityScore(ctx.user.location, event.location, radiusMi: radiusMi)
    add(.proximity, proximity, String(format: "%.1f mi away", distanceMi))

    let attendeeSet = Set(event.attendeeIds)
    let attending = ctx.networkIds.filter { attendeeSet.contains($0) }.count
    let networkValue = ctx.networkIds.isEmpty ? 0 : Double(attending) / Double(ctx.networkIds.count)
    add(
        .networkAttendance,
        networkValue,
        attending == 1 ? "1 person you know is going" : "\(attending) people you know are going"
    )

    if ctx.seenEventIds.contains(event.id) {
        factors.append(
            Factor(
                id: .recencyPenalty,
                value: 1,
                contribution: -Weights[.recencyPenalty],
                reason: "Already shown recently"
            )
        )
    }

    let score = factors.reduce(0) { $0 + $1.contribution }
    // Sorting carries the original index so equal contributions keep the order
    // the factors were added in — Swift's sort is not stable on its own.
    let topFactors = factors
        .enumerated()
        .filter { $0.element.contribution > 0 && !$0.element.reason.isEmpty }
        .sorted { a, b in
            a.element.contribution == b.element.contribution
                ? a.offset < b.offset
                : a.element.contribution > b.element.contribution
        }
        .prefix(2)
        .map(\.element)

    return ScoredEvent(
        event: event,
        score: score,
        factors: factors,
        topFactors: topFactors,
        distanceMi: distanceMi
    )
}

public func rankEvents(_ events: [LotivityEvent], _ ctx: ScoreContext) -> [ScoredEvent] {
    events
        .map { scoreEvent($0, ctx) }
        // Ties break on id, so the order never depends on how the candidates
        // happened to arrive (FR-REC-1).
        .sorted { a, b in
            a.score == b.score ? a.event.id < b.event.id : a.score > b.score
        }
}
