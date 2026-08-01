import Foundation

public let fixtureSeed: UInt32 = 20_260_728

/// Timestamps are generated relative to a fixed anchor rather than "now", so a
/// demo run months from now still shows a plausible mix of past and future.
/// The repo layer rebases these onto the current date at read time.
public let fixtureAnchor = Date(timeIntervalSince1970: 1_785_240_000) // 2026-07-28T12:00:00Z

private enum Volumes {
    static let users = 64
    static let businesses = 26
    static let events = 44
    static let groups = 14
    static let requests = 9
    static let posts = 84
}

private let dayInterval: TimeInterval = 86_400

private let utcCal: Calendar = {
    var cal = Calendar(identifier: .gregorian)
    cal.timeZone = TimeZone(secondsFromGMT: 0)!
    return cal
}()

private func shiftDays(_ base: Date, _ days: Int) -> Date {
    base.addingTimeInterval(Double(days) * dayInterval)
}

private func shiftHours(_ base: Date, _ hours: Int) -> Date {
    base.addingTimeInterval(Double(hours) * 3_600)
}

/// Hours people actually gather, in New York local time.
private let eventHoursET = [7, 8, 9, 10, 11, 12, 13, 17, 18, 19, 20]
private let morningHoursET = [7, 8, 9, 10]
private let eveningHoursET = [17, 18, 19, 20]
private let etUTCOffset = 4 // EDT; the fixture world is a single summer metro.

/// A title that says "night" scheduled at 9 a.m. reads as broken, so titles
/// naming a time of day constrain the hours they can be scheduled at.
func hoursForTitle(_ title: String) -> [Int] {
    let t = title.lowercased()
    let eveningWords = ["night", "evening", "open mic", "happy hour", "sunset", "showcase"]
    if eveningWords.contains(where: { t.contains($0) }) || containsWord(t, "social") {
        return eveningHoursET
    }
    if ["morning", "sunrise", "breakfast", "commute"].contains(where: { t.contains($0) }) {
        return morningHoursET
    }
    if t.contains("afternoon") { return [13, 14, 15] }
    return eventHoursET
}

/// `social\b` in the original — matches "social" only at a word boundary, so
/// "socializing" would not qualify.
private func containsWord(_ haystack: String, _ word: String) -> Bool {
    var searchRange = haystack.startIndex..<haystack.endIndex
    while let found = haystack.range(of: word, range: searchRange) {
        let after = found.upperBound
        if after == haystack.endIndex || !haystack[after].isLetter && !haystack[after].isNumber
            && haystack[after] != "_" {
            return true
        }
        searchRange = after..<haystack.endIndex
    }
    return false
}

/// Pins a date to a plausible local hour rather than an arbitrary offset.
private func atLocalHour(_ day: Date, _ hourET: Int, _ minutes: Int) -> Date {
    var components = utcCal.dateComponents([.year, .month, .day], from: day)
    components.hour = hourET + etUTCOffset
    components.minute = minutes
    components.second = 0
    components.nanosecond = 0
    return utcCal.date(from: components)!
}

/// Scatter a point up to ~0.4 mi from a neighborhood center.
private func jitter(_ rng: RNG, _ center: GeoPoint) -> GeoPoint {
    let north = rng.float(-0.4, 0.4)
    let east = rng.float(-0.4, 0.4)
    return offsetPoint(center, miNorth: north, miEast: east)
}

private let generationDobRanges: [Generation: (Int, Int)] = [
    .alpha: (2013, 2016),
    .genz: (1997, 2008),
    .millennial: (1981, 1996),
    .genx: (1965, 1980),
    .boomer: (1946, 1964),
    .silent: (1938, 1945),
]

private func dobForGeneration(_ rng: RNG, _ gen: Generation) -> String {
    let (from, to) = generationDobRanges[gen]!
    let year = rng.int(from, to)
    let month = String(format: "%02d", rng.int(1, 12))
    let day = String(format: "%02d", rng.int(1, 28))
    return "\(year)-\(month)-\(day)"
}

private func makeUsers(_ rng: RNG) -> [User] {
    // Weighted so adults dominate but every segment is represented (PRD §2).
    let generationPool: [Generation] =
        Array(repeating: .genz, count: 4)
        + Array(repeating: .millennial, count: 7)
        + Array(repeating: .genx, count: 4)
        + Array(repeating: .boomer, count: 3)
        + [.silent, .alpha]

    return (0..<Volumes.users).map { i in
        let generation = rng.pick(generationPool)
        let dob = dobForGeneration(rng, generation)
        let hood = rng.pick(neighborhoods)
        let accountType: AccountType
        if generation == .alpha {
            accountType = .youth
        } else if generation == .silent || (generation == .boomer && rng.chance(0.55)) {
            accountType = .retired
        } else {
            accountType = .adult
        }

        let chosenInterests = rng.sample(interests, 6)

        let name = "\(rng.pick(firstNames)) \(rng.pick(lastNames))"
        let heritageCount = rng.int(1, 2)
        let heritageIDs = rng.sample(heritages, heritageCount).map(\.id)
        let extraLanguageCount = rng.int(0, 2)
        let userLanguages = ["English"]
            + rng.sample(languages.filter { $0 != "English" }, extraLanguageCount)
        var culture: [ID] = []
        if rng.chance(0.6) { culture.append(rng.pick(faithTags).id) }
        let communityCount = rng.int(0, 2)
        culture += rng.sample(communityTags, communityCount).map(\.id)
        // The chances are rolled for every interest first, then a subcategory is
        // picked for the survivors — the JS filter/map does exactly that.
        let narrowed = chosenInterests.filter { _ in rng.chance(0.5) }
        let subcategories = narrowed.map { rng.pick($0.subcategories).id }
        let location = jitter(rng, hood.center)

        return User(
            id: "user:\(i + 1)",
            name: name,
            dob: dob,
            generation: generationFromDob(dob),
            accountType: accountType,
            heritage: heritageIDs,
            languages: userLanguages,
            cultureTags: culture,
            interests: chosenInterests.map(\.id),
            interestSubcategories: subcategories,
            location: location,
            isGuest: false,
            youthVerification: accountType == .youth
                ? YouthVerification(status: .verified, guardianName: "Community host")
                : nil
        )
    }
}

private func makeBusinesses(_ rng: RNG) -> [Business] {
    (0..<Volumes.businesses).map { i in
        let hood = rng.pick(neighborhoods)
        let isFood = rng.chance(0.6)
        let suffix = isFood
            ? rng.pick(rng.chance(0.5) ? cafeSuffixes : restaurantSuffixes)
            : rng.pick(rng.chance(0.5) ? studioSuffixes : venueSuffixes)

        let name = "\(rng.pick(venuePrefixes)) \(suffix)"
        let category = isFood
            ? rng.pick(["Coffee shop", "Restaurant", "Bakery"])
            : rng.pick(["Studio", "Event space", "Community hall"])
        let location = jitter(rng, hood.center)
        var valueTags: [ID] = []
        if rng.chance(0.4) { valueTags.append(rng.pick(faithTags).id) }
        let communityCount = rng.int(0, 2)
        valueTags += rng.sample(communityTags, communityCount).map(\.id)
        let votes = rng.int(3, 92)

        return Business(
            id: "biz:\(i + 1)",
            name: name,
            category: category,
            mapFilter: isFood ? .food : .workshops,
            location: location,
            neighborhood: hood.name,
            valueTags: valueTags,
            // ~15 in network, per the PRD launch target.
            inNetwork: i < 15,
            positiveVotes7d: votes
        )
    }
}

private func makeEvents(_ rng: RNG, _ users: [User], _ businesses: [Business]) -> [LotivityEvent] {
    let categories: [EventCategory] = [.social, .sports, .volunteer, .paid, .work]
    // Templates repeat across 44 events; identical adjacent titles read as a bug.
    var usedTitles = Set<String>()

    return (0..<Volumes.events).map { i in
        let hood = rng.pick(neighborhoods)
        let interest = rng.pick(interests)
        let venue = rng.pick(businesses)
        let templates = eventTitleTemplates[interest.id] ?? ["{neighborhood} meetup"]
        let baseTitle = rng.pick(templates)
            .replacingOccurrences(of: "{neighborhood}", with: hood.name)
            .replacingOccurrences(of: "{place}", with: venue.name)
        let title = usedTitles.contains(baseTitle) ? "\(baseTitle) — \(hood.name)" : baseTitle
        usedTitles.insert(title)

        // Roughly a third in the past so recaps and 7-day windows have material.
        let dayOffset = i % 3 == 0 ? rng.int(-13, -1) : rng.int(0, 21)
        let hour = rng.pick(hoursForTitle(title))
        let minute = rng.pick([0, 30])
        let startsAt = atLocalHour(shiftDays(fixtureAnchor, dayOffset), hour, minute)
        let attendeeCount = rng.int(4, 22)
        let attendees = rng.sample(users, attendeeCount).map(\.id)
        let requiresGuardian = rng.chance(0.18)

        let hostId = rng.chance(0.5) ? venue.id : rng.pick(users).id
        let hostType: LotivityEvent.HostType = rng.chance(0.5) ? .business : .user
        let category = rng.pick(categories)
        let location = jitter(rng, hood.center)
        let endsAt = shiftHours(startsAt, rng.int(1, 4))
        let extraInterestCount = rng.int(0, 1)
        let interestTags = [interest.id] + rng.sample(interests, extraInterestCount).map(\.id)
        let heritageTags = rng.chance(0.35) ? rng.sample(heritages, 1).map(\.id) : []
        var eventCulture: [ID] = []
        if rng.chance(0.3) { eventCulture.append(rng.pick(faithTags).id) }
        if rng.chance(0.3) { eventCulture.append(rng.pick(communityTags).id) }
        let generationCount = rng.int(1, 3)
        let generationTags = rng.sample(
            [.genz, .millennial, .genx, .boomer, .silent, .alpha] as [Generation],
            generationCount
        )
        let interestedCount = rng.int(3, 18)
        let interestedIds = rng.sample(users, interestedCount).map(\.id)
        let sponsoredBy = rng.chance(0.25)
            ? rng.pick(businesses.filter(\.inNetwork)).id
            : nil
        let priceLabel = rng.chance(0.3) ? "$\(rng.int(5, 30))" : nil

        return LotivityEvent(
            id: "event:\(i + 1)",
            title: title,
            hostId: hostId,
            hostType: hostType,
            category: category,
            location: location,
            neighborhood: hood.name,
            venueId: venue.id,
            startsAt: startsAt,
            endsAt: endsAt,
            interestTags: interestTags,
            heritageTags: heritageTags,
            cultureTags: eventCulture,
            generationTags: generationTags,
            attendeeIds: attendees,
            interestedIds: interestedIds,
            requiresGuardian: requiresGuardian,
            sponsoredBy: sponsoredBy,
            priceLabel: priceLabel
        )
    }
}

private func makeGroups(_ rng: RNG, _ users: [User], _ businesses: [Business]) -> [Group] {
    let inNetwork = businesses.filter(\.inNetwork)

    return (0..<Volumes.groups).map { i in
        let hood = rng.pick(neighborhoods)
        let interest = rng.pick(interests)
        let name = rng.pick(groupNameTemplates)
            .replacingOccurrences(of: "{neighborhood}", with: hood.name)
            .replacingOccurrences(of: "{interest}", with: interest.label)

        let roll = rng.next()
        let sponsorState: Sponsorship.State = roll < 0.35 ? .sponsored : (roll < 0.6 ? .pending : .none)
        let sponsor = rng.pick(inNetwork)

        let category = rng.pick([.social, .sports, .volunteer, .paid] as [EventCategory])
        let memberCount = rng.int(5, 28)
        let memberIds = rng.sample(users, memberCount).map(\.id)
        let radiusMi = Double(rng.pick([1, 2, 3, 5]))
        let center = jitter(rng, hood.center)
        let groupCulture: [ID] = rng.chance(0.4) ? [rng.pick(faithTags + communityTags).id] : []

        let sponsorship: Sponsorship
        switch sponsorState {
        case .sponsored:
            let slug = String(name.lowercased().filter { $0.isASCII && $0.isLetter }.prefix(12))
            sponsorship = Sponsorship(state: .sponsored, businessId: sponsor.id, promoCode: "lotivity\(slug)")
        case .pending:
            sponsorship = Sponsorship(state: .pending, businessId: sponsor.id)
        case .none:
            sponsorship = Sponsorship(state: .none)
        }

        return Group(
            id: "group:\(i + 1)",
            name: name,
            category: category,
            description: "A \(interest.label.lowercased()) group meeting regularly around \(hood.name).",
            memberIds: memberIds,
            radiusMi: radiusMi,
            center: center,
            neighborhood: hood.name,
            interestTags: [interest.id],
            cultureTags: groupCulture,
            sponsorship: sponsorship
        )
    }
}

private func makeRequests(_ rng: RNG, _ users: [User], _ groups: [Group]) -> [ActivityRequest] {
    (0..<Volumes.requests).map { i in
        let hood = rng.pick(neighborhoods)
        let threshold = rng.pick([25, 40, 50])
        let upvotes = rng.int(4, Int((Double(threshold) * 1.3).rounded()))

        let authorId = rng.pick(users).id
        let radiusMi = Double(rng.pick([1, 2, 3, 5]))
        let center = jitter(rng, hood.center)
        let interestCount = rng.int(1, 2)
        let targetInterests = rng.sample(interests, interestCount).map(\.id)
        let targetCulture: [ID] = rng.chance(0.5) ? [rng.pick(faithTags + communityTags).id] : []
        let generationCount = rng.int(1, 3)
        let targetGenerations = rng.sample(
            [.genz, .millennial, .genx, .boomer] as [Generation],
            generationCount
        )
        let notifiedCount = rng.int(40, 480)

        return ActivityRequest(
            id: "request:\(i + 1)",
            authorId: authorId,
            description: requestTemplates[i % requestTemplates.count],
            radiusMi: radiusMi,
            center: center,
            targetInterests: targetInterests,
            targetCulture: targetCulture,
            targetGenerations: targetGenerations,
            notifiedCount: notifiedCount,
            upvotes: upvotes,
            upvoteThreshold: threshold,
            resolvedGroupId: upvotes >= threshold ? rng.pick(groups).id : nil
        )
    }
}

private func makePosts(
    _ rng: RNG,
    _ users: [User],
    _ events: [LotivityEvent],
    _ businesses: [Business]
) -> [Post] {
    let pastEvents = events.filter { $0.startsAt < fixtureAnchor }

    return (0..<Volumes.posts).map { i in
        let attachToEvent = rng.chance(0.75) && !pastEvents.isEmpty
        let event = rng.pick(pastEvents.isEmpty ? events : pastEvents)
        let createdAt = attachToEvent
            ? shiftHours(event.endsAt, rng.int(1, 20))
            : shiftDays(fixtureAnchor, rng.int(-9, -1))

        let hasVoice = rng.chance(0.28)

        let authorId: ID
        if attachToEvent && !event.attendeeIds.isEmpty {
            authorId = event.attendeeIds[rng.int(0, event.attendeeIds.count - 1)]
        } else {
            authorId = rng.pick(users).id
        }
        let businessId: ID? = attachToEvent ? nil : rng.pick(businesses).id

        var voiceMemo: VoiceMemo?
        if hasVoice {
            let duration = rng.int(8, 62)
            voiceMemo = VoiceMemo(
                blobKey: "seeded-memo:\(i + 1)",
                durationSec: duration,
                sentiment: rng.chance(0.82) ? .positive : .neutral
            )
        }

        return Post(
            id: "post:\(i + 1)",
            authorId: authorId,
            eventId: attachToEvent ? event.id : nil,
            businessId: businessId,
            body: postBodies[i % postBodies.count],
            media: [],
            voiceMemo: voiceMemo,
            createdAt: createdAt,
            // The 7-day window (FR-SOCIAL-2) is baked into the data, not just the UI.
            visibleUntil: shiftDays(createdAt, 7)
        )
    }
}

private func makeConnections(_ rng: RNG, _ users: [User], _ events: [LotivityEvent]) -> [Connection] {
    var out: [Connection] = []
    for user in users.prefix(30) {
        let peerCount = rng.int(2, 7)
        for peer in rng.sample(users, peerCount) {
            if peer.id == user.id { continue }
            let origin = rng.pick([.invite, .contacts, .sharedEvent] as [Connection.Origin])
            let event = rng.pick(events)
            out.append(
                Connection(
                    userId: user.id,
                    peerId: peer.id,
                    origin: origin,
                    sharedEventId: origin == .sharedEvent ? event.id : nil,
                    connectedAt: shiftDays(fixtureAnchor, -rng.int(1, 300))
                )
            )
        }
    }
    return out
}

public struct World: Sendable {
    public var users: [User]
    public var businesses: [Business]
    public var events: [LotivityEvent]
    public var groups: [Group]
    public var requests: [ActivityRequest]
    public var posts: [Post]
    public var connections: [Connection]
}

/// Builds the entire fixture world. Deterministic for a given seed.
func generateWorld(seed: UInt32 = fixtureSeed) -> World {
    let rng = RNG(seed: seed)
    let users = makeUsers(rng)
    let businesses = makeBusinesses(rng)
    let events = makeEvents(rng, users, businesses)
    let groups = makeGroups(rng, users, businesses)
    let requests = makeRequests(rng, users, groups)
    let posts = makePosts(rng, users, events, businesses)
    let connections = makeConnections(rng, users, events)

    return World(
        users: users,
        businesses: businesses,
        events: events,
        groups: groups,
        requests: requests,
        posts: posts,
        connections: connections
    )
}
