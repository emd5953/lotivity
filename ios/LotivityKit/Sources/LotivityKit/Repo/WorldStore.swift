import Foundation

/// Fixture timestamps are authored against a fixed anchor so the seed is
/// deterministic. At read time we slide the whole world onto the current date,
/// so "3 days from now" stays 3 days from now no matter when the demo runs.
private func rebase(_ world: World, now: Date) -> World {
    // Whole days only: a partial-day shift would drag every event off its
    // authored hour and produce 2 a.m. book clubs.
    let delta = (now.timeIntervalSince(fixtureAnchor) / 86_400).rounded() * 86_400
    func shift(_ date: Date) -> Date { date.addingTimeInterval(delta) }

    var out = world
    out.events = world.events.map {
        var e = $0
        e.startsAt = shift(e.startsAt)
        e.endsAt = shift(e.endsAt)
        return e
    }
    out.posts = world.posts.map {
        var p = $0
        p.createdAt = shift(p.createdAt)
        p.visibleUntil = shift(p.visibleUntil)
        return p
    }
    out.connections = world.connections.map {
        var c = $0
        c.connectedAt = shift(c.connectedAt)
        return c
    }
    return out
}

/// The single source of fixture data. Everything else in `Repo` reads from
/// here; features never build a world directly (BR-1).
public final class WorldStore: @unchecked Sendable {
    public static let shared = WorldStore()

    private let lock = NSLock()
    private var cached: (world: World, builtFor: String)?

    private static let dayKeyFormatter: DateFormatter = {
        let f = DateFormatter()
        f.calendar = Calendar(identifier: .gregorian)
        f.timeZone = TimeZone(secondsFromGMT: 0)
        f.locale = Locale(identifier: "en_US_POSIX")
        f.dateFormat = "yyyy-MM-dd"
        return f
    }()

    public func world(now: Date = Date()) -> World {
        // Rebasing daily is enough — nothing in the UI depends on sub-day drift.
        let key = Self.dayKeyFormatter.string(from: now)
        lock.lock()
        defer { lock.unlock() }

        if let cached, cached.builtFor == key { return cached.world }
        let built = rebase(generateWorld(), now: now)
        cached = (built, key)
        return built
    }

    /// Test helper — forces the next `world(now:)` to rebuild.
    public func reset() {
        lock.lock()
        cached = nil
        lock.unlock()
    }
}

public func getWorld(now: Date = Date()) -> World {
    WorldStore.shared.world(now: now)
}

public func resetWorldCache() {
    WorldStore.shared.reset()
}
