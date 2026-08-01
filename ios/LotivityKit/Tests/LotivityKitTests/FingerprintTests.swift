import XCTest
@testable import LotivityKit

/// Canonical, order-sensitive dump of the fixture world, matching
/// `src/data/fixtures/fingerprint.test.ts` line for line. Running both and
/// diffing is how the claim "the Swift world is the JavaScript world" is
/// checked rather than assumed.
func fingerprint(seed: UInt32) -> String {
    let w = generateWorld(seed: seed)

    func g(_ p: GeoPoint) -> String {
        String(format: "%.9f,%.9f", p.lat, p.lng)
    }

    let iso: ISO8601DateFormatter = {
        let f = ISO8601DateFormatter()
        f.formatOptions = [.withInternetDateTime]
        f.timeZone = TimeZone(secondsFromGMT: 0)
        return f
    }()
    func t(_ d: Date) -> String { iso.string(from: d) }

    var lines: [String] = []

    for u in w.users {
        lines.append([
            u.id, u.name, u.dob, u.generation.rawValue, u.accountType.rawValue,
            u.heritage.joined(separator: "+"), u.languages.joined(separator: "+"),
            u.cultureTags.joined(separator: "+"), u.interests.joined(separator: "+"),
            u.interestSubcategories.joined(separator: "+"),
            g(u.location), "\(u.isGuest)", u.youthVerification?.status.rawValue ?? "-",
        ].joined(separator: "|"))
    }
    for b in w.businesses {
        lines.append([
            b.id, b.name, b.category, b.mapFilter.rawValue, b.neighborhood,
            b.valueTags.joined(separator: "+"), "\(b.inNetwork)", "\(b.positiveVotes7d)",
            g(b.location),
        ].joined(separator: "|"))
    }
    for e in w.events {
        lines.append([
            e.id, e.title, e.hostId, e.hostType.rawValue, e.category.rawValue, e.neighborhood,
            e.venueId ?? "-", t(e.startsAt), t(e.endsAt), e.interestTags.joined(separator: "+"),
            e.heritageTags.joined(separator: "+"), e.cultureTags.joined(separator: "+"),
            e.generationTags.map(\.rawValue).joined(separator: "+"),
            e.attendeeIds.joined(separator: "+"), e.interestedIds.joined(separator: "+"),
            "\(e.requiresGuardian)", e.sponsoredBy ?? "-", e.priceLabel ?? "-", g(e.location),
        ].joined(separator: "|"))
    }
    for gr in w.groups {
        lines.append([
            gr.id, gr.name, gr.category.rawValue, gr.description,
            gr.memberIds.joined(separator: "+"), formatNumber(gr.radiusMi), g(gr.center),
            gr.neighborhood, gr.interestTags.joined(separator: "+"),
            gr.cultureTags.joined(separator: "+"), gr.sponsorship.state.rawValue,
            gr.sponsorship.businessId ?? "-", gr.sponsorship.promoCode ?? "-",
        ].joined(separator: "|"))
    }
    for r in w.requests {
        lines.append([
            r.id, r.authorId, r.description, formatNumber(r.radiusMi), g(r.center),
            r.targetInterests.joined(separator: "+"), r.targetCulture.joined(separator: "+"),
            r.targetGenerations.map(\.rawValue).joined(separator: "+"),
            "\(r.notifiedCount)", "\(r.upvotes)", "\(r.upvoteThreshold)",
            r.resolvedGroupId ?? "-",
        ].joined(separator: "|"))
    }
    for p in w.posts {
        let memo = p.voiceMemo.map { "\($0.blobKey):\($0.durationSec):\($0.sentiment.rawValue)" }
        lines.append([
            p.id, p.authorId, p.eventId ?? "-", p.businessId ?? "-", p.body, memo ?? "-",
            t(p.createdAt), t(p.visibleUntil),
        ].joined(separator: "|"))
    }
    for c in w.connections {
        lines.append([
            c.userId, c.peerId, c.origin.rawValue, c.sharedEventId ?? "-", t(c.connectedAt),
        ].joined(separator: "|"))
    }

    return lines.joined(separator: "\n")
}

/// Whole radii print as `2`, not `2.0` — the JS side has no Double/Int split.
private func formatNumber(_ value: Double) -> String {
    value == value.rounded() ? String(Int(value)) : String(value)
}

final class FingerprintTests: XCTestCase {
    /// Writes the dump when FINGERPRINT_OUT is set; otherwise just exercises it.
    func testWritesTheCanonicalDump() throws {
        let text = "\(fingerprint(seed: 20_260_728))\n---\n\(fingerprint(seed: 42))"
        if let path = ProcessInfo.processInfo.environment["FINGERPRINT_OUT"] {
            try text.write(toFile: path, atomically: true, encoding: .utf8)
        }
        XCTAssertGreaterThan(text.count, 1000)
    }
}
