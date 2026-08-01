import Foundation

public struct MapItem: Identifiable, Hashable, Sendable {
    public enum Kind: String, Sendable { case event, group, business }

    public let id: ID
    public let kind: Kind
    public let filter: MapFilter
    public let title: String
    public let subtitle: String
    public let location: GeoPoint
    public let distanceMi: Double
}

/// Async by design: these signatures are what a real API will return, so
/// swapping the fixture backing is a change confined to this type (BR-1).
public enum Repo {

    /// Strips date of birth. This is the only place a `User` becomes shareable,
    /// which is what keeps FR-PROF-2 true regardless of what views do (BR-5).
    public static func toPublicUser(_ user: User) -> PublicUser {
        PublicUser(
            id: user.id,
            name: user.name,
            generation: user.generation,
            accountType: user.accountType,
            heritage: user.heritage,
            languages: user.languages,
            cultureTags: user.cultureTags,
            relationshipStatus: user.relationshipStatus,
            interests: user.interests,
            interestSubcategories: user.interestSubcategories,
            location: user.location,
            isGuest: user.isGuest,
            youthVerification: user.youthVerification
        )
    }

    public static func publicUser(id: ID) async -> PublicUser? {
        getWorld().users.first { $0.id == id }.map(toPublicUser)
    }

    public static func publicUsers(ids: [ID]) async -> [PublicUser] {
        let wanted = Set(ids)
        return getWorld().users.filter { wanted.contains($0.id) }.map(toPublicUser)
    }

    public static func event(id: ID) async -> LotivityEvent? {
        getWorld().events.first { $0.id == id }
    }

    public static func business(id: ID) async -> Business? {
        getWorld().businesses.first { $0.id == id }
    }

    public static func group(id: ID) async -> Group? {
        getWorld().groups.first { $0.id == id }
    }

    /// Future events only, soonest first — the candidate pool for ranking.
    public static func upcomingEvents(now: Date = Date()) async -> [LotivityEvent] {
        getWorld(now: now).events
            .filter { $0.startsAt >= now }
            .sorted { $0.startsAt == $1.startsAt ? $0.id < $1.id : $0.startsAt < $1.startsAt }
    }

    public static func pastEvents(now: Date = Date()) async -> [LotivityEvent] {
        getWorld(now: now).events
            .filter { $0.endsAt < now }
            .sorted { $0.startsAt == $1.startsAt ? $0.id < $1.id : $0.startsAt > $1.startsAt }
    }

    public static func groups() async -> [Group] { getWorld().groups }

    public static func activityRequests() async -> [ActivityRequest] { getWorld().requests }

    public static func businesses() async -> [Business] { getWorld().businesses }

    /// Event posts are visible for 7 days, and only to people who attended or
    /// were interested (FR-SOCIAL-2). Enforced here so the rule survives a real
    /// backend.
    public static func visiblePosts(viewerId: ID, now: Date = Date()) async -> [Post] {
        let world = getWorld(now: now)
        let eventsByID = Dictionary(uniqueKeysWithValues: world.events.map { ($0.id, $0) })

        let posts = world.posts.filter { post in
            if post.visibleUntil < now { return false }
            guard let eventId = post.eventId else { return true }
            guard let event = eventsByID[eventId] else { return false }
            return post.authorId == viewerId
                || event.attendeeIds.contains(viewerId)
                || event.interestedIds.contains(viewerId)
        }

        return posts.sorted {
            $0.createdAt == $1.createdAt ? $0.id < $1.id : $0.createdAt > $1.createdAt
        }
    }

    public static func connections(userId: ID) async -> [Connection] {
        getWorld().connections.filter { $0.userId == userId }
    }

    /// Everything pinnable within the radius, already filtered and measured.
    public static func mapItems(
        center: GeoPoint,
        radiusMi: Double,
        filters: Set<MapFilter>,
        now: Date = Date()
    ) async -> [MapItem] {
        let world = getWorld(now: now)
        var items: [MapItem] = []

        if filters.contains(.events) {
            for event in world.events {
                if event.startsAt < now { continue }
                if !withinRadius(center, event.location, radiusMi: radiusMi) { continue }
                items.append(
                    MapItem(
                        id: event.id,
                        kind: .event,
                        filter: .events,
                        title: event.title,
                        subtitle: event.neighborhood,
                        location: event.location,
                        distanceMi: distanceMiles(center, event.location)
                    )
                )
            }
        }

        if filters.contains(.clubs) {
            for group in world.groups {
                if !withinRadius(center, group.center, radiusMi: radiusMi) { continue }
                items.append(
                    MapItem(
                        id: group.id,
                        kind: .group,
                        filter: .clubs,
                        title: group.name,
                        subtitle: "\(group.memberIds.count) members · \(group.neighborhood)",
                        location: group.center,
                        distanceMi: distanceMiles(center, group.center)
                    )
                )
            }
        }

        for business in world.businesses {
            if !filters.contains(business.mapFilter) { continue }
            if !withinRadius(center, business.location, radiusMi: radiusMi) { continue }
            items.append(
                MapItem(
                    id: business.id,
                    kind: .business,
                    filter: business.mapFilter,
                    title: business.name,
                    subtitle: "\(business.category) · \(business.neighborhood)",
                    location: business.location,
                    distanceMi: distanceMiles(center, business.location)
                )
            )
        }

        return items.sorted {
            $0.distanceMi == $1.distanceMi ? $0.id < $1.id : $0.distanceMi < $1.distanceMi
        }
    }

    /// Places the viewer's network has been in the last 7 days (FR-MAP-5).
    public static func networkTrail(userId: ID, now: Date = Date()) async -> [MapItem] {
        let world = getWorld(now: now)
        let peers = Set(world.connections.filter { $0.userId == userId }.map(\.peerId))
        let cutoff = now.addingTimeInterval(-7 * 86_400)

        return world.events
            .filter { event in
                guard event.endsAt <= now, event.endsAt >= cutoff else { return false }
                return event.attendeeIds.contains { peers.contains($0) }
            }
            .map { event in
                MapItem(
                    id: event.id,
                    kind: .event,
                    filter: .events,
                    title: event.title,
                    subtitle: "\(event.attendeeIds.filter { peers.contains($0) }.count) in your network went",
                    location: event.location,
                    distanceMi: 0
                )
            }
    }
}
