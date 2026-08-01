import Foundation

/// Domain types — the contract between features and the repository layer.
/// Mirrors docs/TECHNICAL_REQUIREMENTS.md §5. A future API returns these shapes
/// unchanged, so nothing here may depend on how fixtures happen to be stored.

public typealias ID = String

public enum Generation: String, Codable, CaseIterable, Sendable {
    case alpha, genz, millennial, genx, boomer, silent
}

public enum AccountType: String, Codable, CaseIterable, Sendable {
    case youth, adult, retired
}

public enum Continent: String, Codable, CaseIterable, Sendable {
    case africa
    case asia
    case europe
    case northAmerica = "north-america"
    case oceania
    case southAmerica = "south-america"
}

public enum EventCategory: String, Codable, CaseIterable, Sendable {
    case sports, paid, volunteer, social, work
}

/// Map filter buckets (FR-MAP-2) — a projection of category + entity kind.
public enum MapFilter: String, Codable, CaseIterable, Sendable {
    case events, clubs, workshops, food
}

public struct GeoPoint: Codable, Hashable, Sendable {
    public var lat: Double
    public var lng: Double

    public init(lat: Double, lng: Double) {
        self.lat = lat
        self.lng = lng
    }
}

public struct Heritage: Codable, Hashable, Identifiable, Sendable {
    public let id: ID
    public let label: String
    public let continent: Continent
    public let country: String
}

public struct InterestSubcategory: Codable, Hashable, Identifiable, Sendable {
    public let id: ID
    public let label: String
}

public struct Interest: Codable, Hashable, Identifiable, Sendable {
    public let id: ID
    public let label: String
    public let emoji: String
    public let subcategories: [InterestSubcategory]
}

/// Culture tags are namespaced (PRD §9.1): `faith:*` and `community:*` are
/// matched independently even though onboarding presents them on one screen.
public enum CultureNamespace: String, Codable, Sendable {
    case faith, community
}

public struct CultureTag: Codable, Hashable, Identifiable, Sendable {
    /// e.g. "faith:christian", "community:latin"
    public let id: ID
    public let namespace: CultureNamespace
    public let label: String
}

public struct YouthVerification: Codable, Hashable, Sendable {
    public enum Status: String, Codable, Sendable {
        case none, pending, verified
    }

    public var status: Status
    public var guardianName: String?

    public init(status: Status, guardianName: String? = nil) {
        self.status = status
        self.guardianName = guardianName
    }
}

/// Full user record. Only ever leaves the repo layer as `PublicUser`.
public struct User: Codable, Hashable, Identifiable, Sendable {
    public var id: ID
    public var name: String
    /// ISO date (yyyy-MM-dd). Never exposed to other users (FR-PROF-2, BR-5).
    public var dob: String
    /// Derived from `dob` — the only age signal shown to others.
    public var generation: Generation
    public var accountType: AccountType
    public var heritage: [ID]
    public var languages: [String]
    public var cultureTags: [ID]
    public var relationshipStatus: String?
    public var interests: [ID]
    public var interestSubcategories: [ID]
    public var location: GeoPoint
    public var isGuest: Bool
    public var youthVerification: YouthVerification?

    public init(
        id: ID,
        name: String,
        dob: String,
        generation: Generation,
        accountType: AccountType,
        heritage: [ID],
        languages: [String],
        cultureTags: [ID],
        relationshipStatus: String? = nil,
        interests: [ID],
        interestSubcategories: [ID],
        location: GeoPoint,
        isGuest: Bool,
        youthVerification: YouthVerification? = nil
    ) {
        self.id = id
        self.name = name
        self.dob = dob
        self.generation = generation
        self.accountType = accountType
        self.heritage = heritage
        self.languages = languages
        self.cultureTags = cultureTags
        self.relationshipStatus = relationshipStatus
        self.interests = interests
        self.interestSubcategories = interestSubcategories
        self.location = location
        self.isGuest = isGuest
        self.youthVerification = youthVerification
    }
}

/// What any other user is allowed to see. Note the absence of `dob` — this is a
/// distinct type rather than a nulled-out field, so "forgetting" to strip it is
/// a compile error rather than a leak (BR-5).
public struct PublicUser: Codable, Hashable, Identifiable, Sendable {
    public var id: ID
    public var name: String
    public var generation: Generation
    public var accountType: AccountType
    public var heritage: [ID]
    public var languages: [String]
    public var cultureTags: [ID]
    public var relationshipStatus: String?
    public var interests: [ID]
    public var interestSubcategories: [ID]
    public var location: GeoPoint
    public var isGuest: Bool
    public var youthVerification: YouthVerification?
}

public struct Business: Codable, Hashable, Identifiable, Sendable {
    public var id: ID
    public var name: String
    public var category: String
    /// Which map filter bucket this business falls into — `food` or `workshops`.
    public var mapFilter: MapFilter
    public var location: GeoPoint
    public var neighborhood: String
    /// Matched against group requests (PRD §5.2). Self-declared — see PRD §10 Q5.
    public var valueTags: [ID]
    public var inNetwork: Bool
    public var positiveVotes7d: Int
}

public struct LotivityEvent: Codable, Hashable, Identifiable, Sendable {
    public var id: ID
    public var title: String
    public var hostId: ID
    public enum HostType: String, Codable, Sendable { case user, group, business }
    public var hostType: HostType
    public var category: EventCategory
    public var location: GeoPoint
    public var neighborhood: String
    public var venueId: ID?
    public var startsAt: Date
    public var endsAt: Date
    public var interestTags: [ID]
    public var heritageTags: [ID]
    public var cultureTags: [ID]
    public var generationTags: [Generation]
    public var attendeeIds: [ID]
    public var interestedIds: [ID]
    /// True when youth accounts may attend — implies a verified adult (FR-PROF-6).
    public var requiresGuardian: Bool
    public var sponsoredBy: ID?
    public var priceLabel: String?

    public init(
        id: ID,
        title: String,
        hostId: ID,
        hostType: HostType,
        category: EventCategory,
        location: GeoPoint,
        neighborhood: String,
        venueId: ID? = nil,
        startsAt: Date,
        endsAt: Date,
        interestTags: [ID] = [],
        heritageTags: [ID] = [],
        cultureTags: [ID] = [],
        generationTags: [Generation] = [],
        attendeeIds: [ID] = [],
        interestedIds: [ID] = [],
        requiresGuardian: Bool = false,
        sponsoredBy: ID? = nil,
        priceLabel: String? = nil
    ) {
        self.id = id
        self.title = title
        self.hostId = hostId
        self.hostType = hostType
        self.category = category
        self.location = location
        self.neighborhood = neighborhood
        self.venueId = venueId
        self.startsAt = startsAt
        self.endsAt = endsAt
        self.interestTags = interestTags
        self.heritageTags = heritageTags
        self.cultureTags = cultureTags
        self.generationTags = generationTags
        self.attendeeIds = attendeeIds
        self.interestedIds = interestedIds
        self.requiresGuardian = requiresGuardian
        self.sponsoredBy = sponsoredBy
        self.priceLabel = priceLabel
    }
}

public struct Sponsorship: Codable, Hashable, Sendable {
    public enum State: String, Codable, Sendable { case none, pending, sponsored }

    public var state: State
    public var businessId: ID?
    public var promoCode: String?
}

public struct Group: Codable, Hashable, Identifiable, Sendable {
    public var id: ID
    public var name: String
    public var category: EventCategory
    public var description: String
    public var memberIds: [ID]
    public var radiusMi: Double
    public var center: GeoPoint
    public var neighborhood: String
    public var interestTags: [ID]
    public var cultureTags: [ID]
    public var sponsorship: Sponsorship
}

public struct ActivityRequest: Codable, Hashable, Identifiable, Sendable {
    public var id: ID
    public var authorId: ID
    public var description: String
    public var radiusMi: Double
    public var center: GeoPoint
    public var targetInterests: [ID]
    public var targetCulture: [ID]
    public var targetGenerations: [Generation]
    /// Simulated in v0 — no notifications are actually sent.
    public var notifiedCount: Int
    public var upvotes: Int
    public var upvoteThreshold: Int
    public var resolvedGroupId: ID?
}

public struct MediaRef: Codable, Hashable, Identifiable, Sendable {
    public var id: ID
    public var kind: String
    /// Fixture art is generated, not fetched.
    public var seed: String
    public var alt: String
}

public struct VoiceMemo: Codable, Hashable, Sendable {
    public enum Sentiment: String, Codable, Sendable { case positive, neutral, negative }

    public var blobKey: String
    public var durationSec: Int
    public var sentiment: Sentiment
}

public struct Post: Codable, Hashable, Identifiable, Sendable {
    public var id: ID
    public var authorId: ID
    public var eventId: ID?
    public var businessId: ID?
    public var body: String
    public var media: [MediaRef]
    public var voiceMemo: VoiceMemo?
    public var createdAt: Date
    /// Enforces the 7-day event-post window (FR-SOCIAL-2).
    public var visibleUntil: Date
}

public struct Connection: Codable, Hashable, Sendable {
    public enum Origin: String, Codable, Sendable {
        case invite, contacts
        case sharedEvent = "shared-event"
    }

    public var userId: ID
    public var peerId: ID
    public var origin: Origin
    public var sharedEventId: ID?
    public var connectedAt: Date
}
