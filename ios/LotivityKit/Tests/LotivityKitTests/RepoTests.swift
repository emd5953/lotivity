import XCTest
@testable import LotivityKit

final class PrivacyTests: XCTestCase {
    override func setUp() {
        super.setUp()
        resetWorldCache()
    }

    func testNeverExposesDobOnAPublicUser() async throws {
        let user = await Repo.publicUser(id: "user:1")
        let unwrapped = try XCTUnwrap(user)
        // PublicUser has no `dob` to expose — the encoded form proves it.
        let json = try JSONSerialization.jsonObject(
            with: JSONEncoder.lotivity.encode(unwrapped)
        ) as? [String: Any]
        XCTAssertNil(json?["dob"])
    }

    func testKeepsGenerationWhichIsTheSignalMeantToBeVisible() async throws {
        let fetched = await Repo.publicUser(id: "user:1")
        let user = try XCTUnwrap(fetched)
        XCTAssertFalse(generationLabel(user.generation).isEmpty)
    }
}

final class FixtureTests: XCTestCase {
    override func setUp() {
        super.setUp()
        resetWorldCache()
    }

    private func etHour(_ date: Date) -> Int {
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = TimeZone(secondsFromGMT: 0)!
        return cal.component(.hour, from: date.addingTimeInterval(-4 * 3_600))
    }

    func testIsDeterministicForAGivenSeed() throws {
        let a = try JSONEncoder.lotivity.encode(WorldSnapshot(generateWorld(seed: 42)))
        let b = try JSONEncoder.lotivity.encode(WorldSnapshot(generateWorld(seed: 42)))
        XCTAssertEqual(a, b)
    }

    func testDiffersAcrossSeedsSoTheDeterminismAboveIsMeaningful() throws {
        let a = try JSONEncoder.lotivity.encode(WorldSnapshot(generateWorld(seed: 1)))
        let b = try JSONEncoder.lotivity.encode(WorldSnapshot(generateWorld(seed: 2)))
        XCTAssertNotEqual(a, b)
    }

    func testMeetsTheVolumesTheTRDCallsFor() {
        let world = getWorld()
        XCTAssertGreaterThanOrEqual(world.users.count, 60)
        XCTAssertGreaterThanOrEqual(world.events.count, 40)
        XCTAssertGreaterThanOrEqual(world.businesses.count, 25)
        XCTAssertGreaterThanOrEqual(world.groups.count, 12)
        XCTAssertGreaterThanOrEqual(world.requests.count, 8)
        XCTAssertGreaterThanOrEqual(world.posts.count, 80)
    }

    func testHasRoughlyFifteenInNetworkBusinesses() {
        XCTAssertEqual(getWorld().businesses.filter(\.inNetwork).count, 15)
    }

    func testSchedulesEveryEventAtAnHourPeopleActuallyGather() {
        // Guards the whole-day rebase: a partial-day shift produced 2 a.m. book clubs.
        for event in getWorld().events {
            XCTAssertGreaterThanOrEqual(etHour(event.startsAt), 7, event.title)
            XCTAssertLessThanOrEqual(etHour(event.startsAt), 20, event.title)
        }
    }

    func testDoesNotScheduleANightEventInTheMorning() {
        for event in getWorld().events {
            let t = event.title.lowercased()
            guard t.contains("night") || t.contains("evening") || t.contains("open mic") else { continue }
            XCTAssertGreaterThanOrEqual(etHour(event.startsAt), 17, event.title)
        }
    }

    func testDoesNotNameAWeekdayInATitle() {
        let weekdays = ["monday", "tuesday", "wednesday", "thursday", "friday", "saturday", "sunday"]
        for event in getWorld().events {
            let t = event.title.lowercased()
            XCTAssertFalse(weekdays.contains { t.contains($0) }, event.title)
        }
    }

    func testGivesEveryEventADistinctTitle() {
        let titles = getWorld().events.map(\.title)
        XCTAssertEqual(Set(titles).count, titles.count)
    }

    func testStartsEventsOnTheHourOrHalfHour() {
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = TimeZone(secondsFromGMT: 0)!
        for event in getWorld().events {
            XCTAssertTrue([0, 30].contains(cal.component(.minute, from: event.startsAt)))
        }
    }

    func testSeedsBothPastAndFutureEventsSoRecapsHaveMaterial() {
        let now = Date()
        let world = getWorld()
        XCTAssertTrue(world.events.contains { $0.startsAt < now })
        XCTAssertTrue(world.events.contains { $0.startsAt > now })
    }
}

final class MapItemsTests: XCTestCase {
    private let allFilters: Set<MapFilter> = [.events, .clubs, .workshops, .food]

    override func setUp() {
        super.setUp()
        resetWorldCache()
    }

    func testReturnsOnlyItemsInsideTheRadius() async {
        let items = await Repo.mapItems(center: defaultCenter, radiusMi: 1, filters: allFilters)
        for item in items {
            XCTAssertLessThanOrEqual(distanceMiles(defaultCenter, item.location), 1)
        }
    }

    func testReturnsStrictlyMoreAsTheRadiusGrows() async {
        let near = await Repo.mapItems(center: defaultCenter, radiusMi: 1, filters: allFilters)
        let far = await Repo.mapItems(center: defaultCenter, radiusMi: 10, filters: allFilters)
        XCTAssertGreaterThan(far.count, near.count)
    }

    func testHonorsFilters() async {
        let items = await Repo.mapItems(center: defaultCenter, radiusMi: 10, filters: [.food])
        XCTAssertGreaterThan(items.count, 0)
        XCTAssertTrue(items.allSatisfy { $0.filter == .food })
    }

    func testSortsNearestFirst() async {
        let items = await Repo.mapItems(center: defaultCenter, radiusMi: 5, filters: [.events])
        XCTAssertEqual(items.map(\.distanceMi), items.map(\.distanceMi).sorted())
    }
}

final class PostVisibilityTests: XCTestCase {
    override func setUp() {
        super.setUp()
        resetWorldCache()
    }

    func testHidesEventPostsFromPeopleWhoNeitherAttendedNorWereInterested() async throws {
        let world = getWorld()
        let eventPost = try XCTUnwrap(world.posts.first { $0.eventId != nil })
        let event = try XCTUnwrap(world.events.first { $0.id == eventPost.eventId })

        let outsider = try XCTUnwrap(
            world.users.first {
                !event.attendeeIds.contains($0.id)
                    && !event.interestedIds.contains($0.id)
                    && $0.id != eventPost.authorId
            }
        )

        let visible = await Repo.visiblePosts(viewerId: outsider.id)
        XCTAssertFalse(visible.contains { $0.id == eventPost.id })
    }

    func testShowsAnEventPostToSomeoneWhoAttended() async throws {
        let now = Date()
        let world = getWorld(now: now)
        // Must still be inside its 7-day window, or expiry masks the attendee rule.
        let eventPost = try XCTUnwrap(
            world.posts.first { post in
                guard let eventId = post.eventId, post.visibleUntil >= now else { return false }
                return !(world.events.first { $0.id == eventId }?.attendeeIds.isEmpty ?? true)
            }
        )
        let event = try XCTUnwrap(world.events.first { $0.id == eventPost.eventId })
        let attendee = try XCTUnwrap(event.attendeeIds.first)

        let visible = await Repo.visiblePosts(viewerId: attendee, now: now)
        XCTAssertTrue(visible.contains { $0.id == eventPost.id })
    }

    func testNeverReturnsAPostPastItsSevenDayWindow() async {
        let now = Date()
        for post in await Repo.visiblePosts(viewerId: "user:1", now: now) {
            XCTAssertGreaterThanOrEqual(post.visibleUntil, now)
        }
    }
}

/// `World` is not `Codable` (nothing persists it), so tests wrap it to compare
/// two generations byte for byte.
private struct WorldSnapshot: Encodable {
    let users: [User]
    let businesses: [Business]
    let events: [LotivityEvent]
    let groups: [Group]
    let requests: [ActivityRequest]
    let posts: [Post]
    let connections: [Connection]

    init(_ world: World) {
        users = world.users
        businesses = world.businesses
        events = world.events
        groups = world.groups
        requests = world.requests
        posts = world.posts
        connections = world.connections
    }
}
