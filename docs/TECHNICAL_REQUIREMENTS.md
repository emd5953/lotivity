# Lotivity — Technical Requirements Document

**Version:** 0.2
**Status:** Draft
**Scope:** Mock native iOS app (v0)
**Last updated:** 2026-07-31

> **v0.2 — platform change.** v0.1 specified a React + Vite Progressive Web App,
> which was built and then retired in favor of a native SwiftUI app. The
> functional requirements, data model, ranking weights, and business rules are
> unchanged and carried over intact; §2, §3, §7, §8, and §10 are rewritten for
> the new platform. The Swift port reproduces the web app's generated world byte
> for byte, so no fixture behavior changed with the move.

---

## 1. Purpose & Scope

This document specifies the technical requirements for **Lotivity v0** — a fully interactive, **mock** native iOS app. The goal is a clickable, demo-ready product that renders every core screen and flow described in the [README](../README.md), backed by fixture data rather than a live backend.

Product rationale — why these features, in this order, for these users — lives in the [PRD](./PRD.md). Where the two documents overlap, the PRD is authoritative on *what* and *why*; this document is authoritative on *how*.

### In scope

- All screens: intro sequence, profile creation, For You, Groups, Social Feed, Map Radius
- Full navigation between them, with realistic seeded content
- Local persistence so a session survives an app restart
- Runs entirely offline — no network call at any point

### Explicitly out of scope for v0

| Deferred | Why |
| --- | --- |
| Real backend, database, server API | Fixtures cover every demo path |
| Real authentication (Google / Apple ID) | Mocked as a one-tap flow |
| Real ID verification for youth accounts | Simulated approval state only |
| Push notifications | Rendered as in-app notification cards |
| Payments, subscriptions, promo-code redemption | Codes are displayed, never validated |
| Business/partner portal | Consumer app only |
| Content moderation, reporting, trust & safety tooling | Requires real users |

Everything deferred must still be **designed around** — see [§9 Backend Readiness](#9-backend-readiness).

---

## 2. Assumptions

Stated because they were chosen, not specified:

1. **iPhone, portrait.** Design target is a 393×852 point screen. iPad runs the same build in a centered column capped at 480 points; landscape is not a design target.
2. **iOS 17 minimum.** Chosen for `@Observable`, `NavigationStack` paths, and SwiftUI `Map` with content builders — all of which remove adapter code that would otherwise exist only to support older systems.
3. **No real user data.** All profiles, events, businesses, and reviews are fixtures. Nothing leaves the device.
4. **Single locale.** English only in v0; copy sits in the views so localization is additive.
5. **One seeded metro area.** The map and radius features operate over a single real city so distances feel plausible.

---

## 3. Technology Stack

| Concern | Choice | Rationale |
| --- | --- | --- |
| Language | Swift 6 toolchain, language mode 5 | Mode 5 is explicit in both targets rather than inherited; strict concurrency is a later, deliberate migration |
| UI | SwiftUI, iOS 17+ | Declarative, and the design system is small enough that UIKit buys nothing |
| Domain layer | A local Swift package, `LotivityKit` | A real module boundary: features cannot reach past `Repo` into fixtures because those symbols are not `public` |
| State | `@Observable` `AppState` in the environment | One store, no third-party dependency |
| Navigation | `TabView`-free custom bar + `NavigationStack` path | Tab labels must be mono, lowercase, olive-when-live; onboarding steps are an enum the compiler checks |
| Map | MapKit | Native, no API key, no tile CDN, no third-party dependency. Radius drawn with `MapCircle` |
| Location | CoreLocation, one-shot when-in-use | Denial falls back to a seeded center rather than a dead end |
| Persistence | JSON file per key in Application Support | Survives relaunch; the right shape for voice-memo blobs later |
| Audio | `AVAudioRecorder` *(not yet built — M6)* | Voice-memo reviews record locally |
| Testing | XCTest in the package | Runs on the host in under a second, no simulator |
| Build | `xcodebuild`, or `ios/run.sh` for build → install → launch | |

**Constraint:** zero third-party dependencies. No runtime dependency requires an API key, account, or paid tier, and the app makes no network request at all — including for map tiles, which MapKit serves through the system.

---

## 4. Functional Requirements

Requirements are labeled `FR-<area>-<n>`. Each must be demonstrable in the running app.

### 4.1 Intro Sequence (`FR-INTRO`)

- **FR-INTRO-1** — On first launch, play a zoom from an Earth view into an animated sketch-style community view.
- **FR-INTRO-2** — The camera path passes five scenes in order: playground, concert venue, coffee shop, pottery class, outdoor running group.
- **FR-INTRO-3** — The sequence ends on the profile entry screen.
- **FR-INTRO-4** — A persistent **Skip** control is available from the first frame.
- **FR-INTRO-5** — The sequence plays once. Returning users land directly on For You; it is replayable from Settings.
- **FR-INTRO-6** — Honor `prefers-reduced-motion`: substitute a static or cross-faded version.
- **FR-INTRO-7** — Total duration ≤ 6 seconds, and it must never block interaction.

### 4.2 Profile Creation (`FR-PROF`)

- **FR-PROF-1** — Three entry paths: *Link Google account*, *Link Apple ID*, *Continue as guest*. In v0 the first two resolve instantly to a mock identity; guest creates an unsaved session profile.
- **FR-PROF-2** — Collect name and date of birth. **DOB is never rendered to other users** — only the derived generation label is.
- **FR-PROF-3** — Derive generation from DOB (Gen Alpha, Gen Z, Millennial, Gen X, Boomer, Silent) and display it as a bubble beside the name.
- **FR-PROF-4** — Account type selection: **Youth**, **General Adult**, **Retired**, shown as sub-bubbles beside the name.
- **FR-PROF-5** — Display the incentive disclaimer at the account-type step: choosing the category that reflects your life unlocks relevant community promotions.
- **FR-PROF-6** — Youth accounts are flagged such that any event they host or attend requires a verified community-appointed host or parent. v0 renders the requirement and a simulated verification state; it does not verify.
- **FR-PROF-7** — **Cultural Heritage Association:** country of location is pre-filled; heritage bubbles nest under continent (Europe, Africa, Asia, Oceania, North America, South America). Multi-select, searchable, ≥ 8 options per continent.
- **FR-PROF-8** — **Languages:** multi-select from a standard language list.
- **FR-PROF-9** — **Religion / Culture bubbles:** multi-select, optional, skippable without penalty.
- **FR-PROF-10** — **Relationship status:** single select, optional.
- **FR-PROF-11** — **Interests:** user picks exactly 6 to proceed; more can be added later from the profile.
- **FR-PROF-12** — Each interest expands to subcategories (e.g. Basketball → organized play, local pickup, outside court, open gym). Subcategory selection is optional.
- **FR-PROF-13** — Show the `Rendering Your Community…` loading state between the final step and For You, for 2–4 seconds.
- **FR-PROF-14** — Every step is back-navigable without data loss; progress persists across reload.

### 4.3 For You (`FR-FEED`)

- **FR-FEED-1** — Ranked mixed feed of events, recaps, activities, and clubs.
- **FR-FEED-2** — Ranking is a transparent local scoring function over interest overlap, heritage match, generation match, and distance. See [§6](#6-mock-recommendation-engine).
- **FR-FEED-3** — Each card shows why it surfaced (e.g. *"Because you follow Running · 1.2 mi away"*).
- **FR-FEED-4** — Heritage-triggered cards render in the notification voice, e.g. *"This Friday, check out Colombian restaurant \_\_\_\_ for happy hour. 55 people with Colombian heritage voted it a positive experience this week."*
- **FR-FEED-5** — Tapping a heritage card's recap link deep-links into the Social Feed filtered to that recap.

### 4.4 Groups & Activity Requests (`FR-GROUP`)

- **FR-GROUP-1** — Create a group and invite people from your network.
- **FR-GROUP-2** — Post a **radius request** for a group to be organized, with a description, radius, and target attributes (interest, religion/culture, generation).
- **FR-GROUP-3** — On submission, simulate notifying matching users in radius and display the matched count.
- **FR-GROUP-4** — Requests accumulate community upvotes. Crossing a configurable threshold moves the request to **Sponsored**.
- **FR-GROUP-5** — A sponsored request is matched to a fixture business with aligned values and renders a proposed time plus a generated promo code (format: `lotivity` + slug, e.g. `lotivityclubchrist`).
- **FR-GROUP-6** — Group detail shows category, members, upcoming meetups, and sponsorship state.
- **FR-GROUP-7** — Club categories organize groups by what they do: sports, paid events, volunteer, social gatherings.

### 4.5 Work Tab (`FR-WORK`)

- **FR-WORK-1** — Browse activities bridging people across industries and companies.
- **FR-WORK-2** — Propose an activity and collect votes (e.g. work happy hour).
- **FR-WORK-3** — Render company-paid activity bundles as a distinct card type.

### 4.6 Social Feed (`FR-SOCIAL`)

- **FR-SOCIAL-1** — **7-day recap** of where your network has been and what they reviewed, tied to the radius map.
- **FR-SOCIAL-2** — Event posts are visible for **7 days after the event**, and only to users who attended or marked interest. Enforce this in the fixture query, not just in the UI.
- **FR-SOCIAL-3** — Follow artists; see recaps from their nearby performances, upcoming local shows, and recaps from their shows elsewhere in the world.
- **FR-SOCIAL-4** — Record a **voice-memo review** on an attended event or visited business, played back inline. Recording earns a displayed discount.
- **FR-SOCIAL-5** — Connections are restricted: you may only connect with someone in your radius, via invite, contact match, or a prior shared event. The UI must state which of the three unlocked a given connection.
- **FR-SOCIAL-6** — Network view lists connections with the context in which you met.

### 4.7 Map Radius (`FR-MAP`)

- **FR-MAP-1** — Interactive map centered on the user, with an adjustable radius control.
- **FR-MAP-2** — Filters: **events · clubs · workshops · food**, independently toggleable.
- **FR-MAP-3** — Pins reflect the active radius and filters; the count updates live.
- **FR-MAP-4** — Tapping a pin opens a detail sheet linking to the event, group, or business.
- **FR-MAP-5** — Overlay showing where your network has been in the last 7 days, toggleable.
- **FR-MAP-6** — Geolocation is requested with rationale; on denial, fall back to a seeded default location without a dead end.

### 4.8 Cross-cutting (`FR-APP`)

- **FR-APP-1** — Bottom tab navigation: For You · Groups · Social · Map · Profile. Work is reachable from For You and Profile.
- **FR-APP-2** — Ships as a normal iOS app: app icon, launch screen, portrait, dark appearance forced (there is no light mode).
- **FR-APP-3** — Offline: every screen and all fixture data render with no network. The world is generated in-process at launch, not fetched or bundled as JSON.
- **FR-APP-4** — All state persists across app restart, including a partially-completed onboarding flow.
- **FR-APP-5** — A **Reset demo** control in Settings clears state and replays the intro.

---

## 5. Data Model (fixtures)

Swift types, shaped so a future API can return them unchanged. Abridged from `LotivityKit/Sources/LotivityKit/Schema.swift`, which is authoritative.

```swift
typealias ID = String

enum Generation: String { case alpha, genz, millennial, genx, boomer, silent }
enum AccountType: String { case youth, adult, retired }

struct GeoPoint { var lat: Double; var lng: Double }

struct User {
    var id: ID
    var name: String
    var dob: String              // yyyy-MM-dd — never exposed to other users
    var generation: Generation   // derived from dob; the only age signal shown
    var accountType: AccountType
    var heritage: [ID]           // → Heritage
    var languages: [String]
    var cultureTags: [ID]        // namespaced: `faith:*` and `community:*` (PRD §9.1)
    var relationshipStatus: String?
    var interests: [ID]          // exactly 6 at signup
    var interestSubcategories: [ID]
    var location: GeoPoint
    var isGuest: Bool
    var youthVerification: YouthVerification?
}

/// What any other user is allowed to see. A distinct type, not `User` with a
/// nulled field — see BR-5.
struct PublicUser { /* every field of User except `dob` */ }

struct Business {
    var id: ID; var name: String; var category: String
    var mapFilter: MapFilter     // `.food` or `.workshops`
    var location: GeoPoint; var neighborhood: String
    var valueTags: [ID]          // matched against group requests
    var inNetwork: Bool          // Lotivity business partner
    var positiveVotes7d: Int
}

struct LotivityEvent {
    var id: ID; var title: String; var hostId: ID
    var hostType: HostType       // .user | .group | .business
    var category: EventCategory  // .sports | .paid | .volunteer | .social | .work
    var location: GeoPoint; var neighborhood: String; var venueId: ID?
    var startsAt: Date; var endsAt: Date
    var interestTags: [ID]; var heritageTags: [ID]; var cultureTags: [ID]
    var generationTags: [Generation]
    var attendeeIds: [ID]; var interestedIds: [ID]
    var requiresGuardian: Bool   // true when youth accounts may attend
    var sponsoredBy: ID?; var priceLabel: String?
}

struct Group {
    var id: ID; var name: String; var category: EventCategory
    var description: String; var memberIds: [ID]
    var radiusMi: Double; var center: GeoPoint; var neighborhood: String
    var interestTags: [ID]; var cultureTags: [ID]
    var sponsorship: Sponsorship // state + businessId? + promoCode?
}

struct ActivityRequest {
    var id: ID; var authorId: ID; var description: String
    var radiusMi: Double; var center: GeoPoint
    var targetInterests: [ID]; var targetCulture: [ID]
    var targetGenerations: [Generation]
    var notifiedCount: Int       // simulated
    var upvotes: Int; var upvoteThreshold: Int
    var resolvedGroupId: ID?
}

struct Post {
    var id: ID; var authorId: ID; var eventId: ID?; var businessId: ID?
    var body: String; var media: [MediaRef]; var voiceMemo: VoiceMemo?
    var createdAt: Date
    var visibleUntil: Date       // enforces the 7-day event-post window
}

struct Connection {
    var userId: ID; var peerId: ID
    var origin: Origin           // .invite | .contacts | .sharedEvent
    var sharedEventId: ID?
    var connectedAt: Date
}
```

Timestamps are `Date` in memory and ISO 8601 on disk and on the wire (BR-3); the JSON coders are configured once in `Persistence.swift`.

### Seed data volume

Enough that filters and radius changes visibly do something:

- 60+ users across all generations and account types
- 40+ events spanning past (with recaps) and future
- 25+ businesses, ~15 in network
- 12+ groups in mixed sponsorship states
- 8+ activity requests at varying upvote counts
- 80+ posts, at least 10 with voice memos

---

## 6. Mock Recommendation Engine

For You ranking is a pure, deterministic, testable function — **no ML, no network**.

```
score = 3.0 × interestOverlap      // fraction of user interests matched
      + 2.0 × heritageMatch        // 1 if any heritage tag matches
      + 1.5 × cultureMatch
      + 1.0 × generationMatch
      + 2.0 × proximityScore       // 1 at 0 mi → 0 at radius edge
      + 1.0 × networkAttendance    // fraction of connections attending
      - 2.0 × recencyPenalty       // decay for items already seen
```

Requirements:

- **FR-REC-1** — Pure function of `(user, candidates, now)`. Same inputs → same order.
- **FR-REC-2** — Emit the top two contributing factors per item to power the "why you're seeing this" line (FR-FEED-3).
- **FR-REC-3** — Weights live in one config module so they can be tuned without touching call sites.
- **FR-REC-4** — Unit-tested: each factor in isolation, plus a full-ranking snapshot.

---

## 7. Non-Functional Requirements

| ID | Requirement |
| --- | --- |
| NFR-1 | Cold launch to an interactive feed in under 1 s on an iPhone 12 or newer |
| NFR-2 | Building the fixture world is synchronous and off the critical path — under 50 ms, cached per calendar day |
| NFR-3 | Intro sequence sustains 60 fps on an iPhone 12 or newer |
| NFR-4 | Zero third-party runtime dependencies; the app binary carries no vendored framework |
| NFR-5 | The domain layer is UI-independent — `LotivityKit` imports only `Foundation` and its tests run without a simulator |
| NFR-6 | Contrast, focus order, labeled controls; Dynamic Type up to XXL without clipping; `accessibilityReduceMotion` respected |
| NFR-7 | Fully operable with VoiceOver; bubble multi-selects expose selected state, not just a label |
| NFR-8 | Persistence failure degrades to an in-memory session — losing the profile is acceptable, crashing is not |
| NFR-9 | Works with the network disabled, including the map, from first launch |
| NFR-10 | No secrets, keys, or real personal data in the repository |

---

## 8. Architecture

```
ios/
  LotivityKit/                  # domain layer — a package, not a folder
    Sources/LotivityKit/
      Schema.swift              # the types features and the repo agree on
      Geo.swift                 # distance, radius, bounds, proximity
      Generation.swift          # DOB → generation, account-type suggestion
      Recommend.swift           # scoring engine + weights
      OnboardingDraft.swift     # the in-progress profile, and the guest identity
      Persistence.swift         # JSON per key, best-effort
      Reference/                # heritage, culture, interests, NYC
      Fixtures/                 # RNG, pools, world generator
      Repo/                     # repository layer — the future API seam
    Tests/LotivityKitTests/
  Lotivity/                     # the app
    LotivityApp.swift
    AppState.swift              # one @Observable store
    Design/                     # Theme, Components, FlowLayout
    Features/
      Onboarding/Steps/         # one file per question
      ForYou/
      Groups/                   # groups + activity requests   (M5, not built)
      Social/                   # feed, recaps, voice memos     (M6, not built)
      Map/
      Profile/
      Placeholder/
```

**The repository layer is the seam.** Every feature reads through `Repo`, which is `async`, returns domain types, and never exposes fixtures directly. Swapping mock for live is a change to one directory.

**The package boundary enforces it.** `LotivityKit` is a separate module, so anything not marked `public` is invisible to the app target. `generateWorld` and the fixture pools are internal — a view *cannot* reach past the repo to the seed data, which in the web version was only a convention.

---

## 9. Backend Readiness

v0 ships no backend, but must not foreclose one:

- **BR-1** — Repository functions are `async` and typed exactly as a future API would return.
- **BR-2** — Entity IDs are opaque strings, never array indices.
- **BR-3** — All timestamps serialize as ISO 8601 UTC.
- **BR-4** — Geospatial queries are isolated in `Geo.swift` so they can move to PostGIS unchanged in behavior.
- **BR-5** — Privacy rules (DOB hidden, radius-gated connections, 7-day post visibility) are enforced in the repository layer, not in views — so they survive the migration to a real server. DOB is enforced by the type system: `PublicUser` has no such field, so exposing one does not compile.
- **BR-6** — Ordering is total. Every sort carries an id tiebreak, so results do not depend on the incidental stability of a sort implementation — the same query returns the same order on a server as it does here.

---

## 10. Testing

| Level | Coverage | Status |
| --- | --- | --- |
| Unit (XCTest, in the package) | Recommendation scoring factor by factor, ranking order and tiebreaks, generation boundaries, geo/radius math, map-item filtering, post-visibility windows, fixture volumes and scheduling sanity | 52 tests, green |
| Fixture integrity | A canonical dump of every field of every record, pinned by digest — any reordered `rng` call fails loudly instead of silently reshuffling the demo | Green; digests carried over from the retired web app |
| UI (XCUITest) | The 6-interest gate, back-navigation without data loss, radius change updates pins and count | **Not written.** The gap in the suite |
| Manual | Onboarding end to end; location denied; airplane mode; VoiceOver pass; Dynamic Type at XXL | Partially exercised |

The web version's Playwright flows were not ported. Two of the three covered surfaces that do not exist yet (M5 sponsorship); the third — onboarding through to the feed — is worth rebuilding as XCUITest before M8.

---

## 11. Milestones

| # | Deliverable | Exit criteria | Status |
| --- | --- | --- | --- |
| M0 | Project scaffold | Xcode project + `LotivityKit` package; builds and runs offline | ✅ |
| M1 | Design system + fixtures | UI primitives built; seed data at target volume | ✅ |
| M2 | Onboarding | FR-PROF-1 → 14 complete and persistent | ✅ |
| M3 | Intro sequence | FR-INTRO-1 → 7, hitting NFR-3 | ⬜ Deferred (PRD P2) |
| M4 | For You + recommendation engine | FR-FEED and FR-REC complete with unit tests | ✅ |
| M5 | Groups, requests, sponsorship | FR-GROUP and FR-WORK complete | ⬜ Data model done, no UI |
| M6 | Social feed + voice memos | FR-SOCIAL complete, including the 7-day window | ⬜ 7-day rule enforced in the repo; no UI |
| M7 | Map radius | FR-MAP complete | ✅ |
| M8 | Polish + audit | All NFRs met; UI suite green; demo script written | ⬜ |

M5 is the one open **P0** item (PRD §6) — the sponsorship loop is the differentiated mechanic and the only priority-zero feature without a surface.

---

## 12. Open Questions

Resolved in [PRD §9](./PRD.md#9-resolved-product-decisions):

- **Map seed** — New York City, real coordinates, fictional venue names (PRD §9.5).
- **Guest profiles** — full read access, no write (PRD §9.3).
- **Culture bubbles** — `faith:*` and `community:*` tagged in separate namespaces, presented on one screen; "Hindi" corrected to **Hindu** (PRD §9.1).

Still open — tracked in [PRD §10](./PRD.md#10-open-questions):

1. Does the intro sequence use hand-drawn illustration, or generated/vector art? *(before M3)*
2. What is the upvote threshold that triggers sponsorship, and does it scale with radius population? *(before M5)*
3. Are voice-memo reviews public to the whole radius, or only to the reviewer's network? *(before M6)*

Provisional answers are already encoded in the fixtures — thresholds of 25/40/50 that do not scale with population, and self-declared business value tags. They are demo defaults, not decisions, and M5 should not ship on them without a deliberate call.

Opened by the platform change:

4. Does the domain layer migrate to Swift 6 strict concurrency, and when? Both targets pin language mode 5 today. Nothing in the design fights it — the world is immutable once built and the one cache is lock-guarded — but it is unmigrated work, not free.
5. Does anything need to run on the web again (a shareable event link, a business portal)? If so, `LotivityKit` is the part that would need a second implementation, and the fingerprint digests are how a port would be verified.
