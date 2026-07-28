# Lotivity — Technical Requirements Document

**Version:** 0.1
**Status:** Draft
**Scope:** Mock Progressive Web App (v0)

---

## 1. Purpose & Scope

This document specifies the technical requirements for **Lotivity v0** — a fully interactive, **mock** Progressive Web App. The goal is a clickable, demo-ready product that renders every core screen and flow described in the [README](../README.md), backed by fixture data rather than a live backend.

Product rationale — why these features, in this order, for these users — lives in the [PRD](./PRD.md). Where the two documents overlap, the PRD is authoritative on *what* and *why*; this document is authoritative on *how*.

### In scope

- All screens: intro sequence, profile creation, For You, Groups, Social Feed, Map Radius
- Full navigation between them, with realistic seeded content
- Local persistence so a session survives a reload
- Installable PWA with offline shell

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

1. **Mobile-first, portrait.** Design target is a 390×844 viewport; the app must remain usable to 1280px wide but is not designed for desktop.
2. **No real user data.** All profiles, events, businesses, and reviews are fixtures. Nothing leaves the device.
3. **Single locale.** English only in v0; copy is externalized so localization is additive.
4. **One seeded metro area.** The map and radius features operate over a single fictional or real city so distances feel plausible.

---

## 3. Technology Stack

| Concern | Choice | Rationale |
| --- | --- | --- |
| Framework | React 18 + TypeScript | Largest component ecosystem; types keep fixtures honest |
| Build / dev server | Vite | Fast HMR; first-class PWA plugin |
| PWA | `vite-plugin-pwa` (Workbox) | Generates manifest + service worker with minimal config |
| Routing | React Router (data router) | Nested layouts match the tab structure |
| Styling | Tailwind CSS + CSS custom properties | Rapid iteration; tokens keep the design system coherent |
| Animation | Framer Motion | Needed for the intro sequence and tab transitions |
| Map | MapLibre GL JS + free raster/vector tiles | No API key required for a mock; swappable for Mapbox later |
| State | Zustand | Minimal boilerplate for profile + session state |
| Persistence | IndexedDB via `idb-keyval` | Survives reload; larger quota than `localStorage` for audio blobs |
| Audio | `MediaRecorder` API | Voice-memo reviews record locally |
| Testing | Vitest + React Testing Library; Playwright for flows | Unit coverage on logic, E2E on the three critical paths |
| Lint / format | ESLint + Prettier | Enforced in CI |

**Constraint:** no runtime dependency requires an API key, account, or paid tier. The app must run offline after first load with `npm install && npm run dev`.

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
- **FR-APP-2** — Installable PWA — manifest, icons (192/512/maskable), splash, standalone display.
- **FR-APP-3** — Offline: app shell and all fixture data load with no network.
- **FR-APP-4** — All state persists across reload and app restart.
- **FR-APP-5** — A **Reset demo** control in Settings clears state and replays the intro.

---

## 5. Data Model (fixtures)

TypeScript interfaces, shaped so a future API can return them unchanged.

```ts
type ID = string;

type Generation = 'alpha' | 'genz' | 'millennial' | 'genx' | 'boomer' | 'silent';
type AccountType = 'youth' | 'adult' | 'retired';

interface User {
  id: ID;
  name: string;
  dob: string;              // ISO date — never exposed to other users
  generation: Generation;   // derived from dob; the only age signal shown
  accountType: AccountType;
  heritage: ID[];           // → Heritage
  languages: string[];      // BCP-47
  cultureTags: ID[];        // namespaced: `faith:*` and `community:*` (PRD §9.1)
  relationshipStatus?: string;
  interests: Interest[];    // exactly 6 at signup
  location: GeoPoint;
  isGuest: boolean;
  youthVerification?: { status: 'none' | 'pending' | 'verified'; guardianName?: string };
}

interface Interest { id: ID; label: string; subcategories: ID[] }
interface Heritage { id: ID; label: string; continent: Continent; country: string }
interface GeoPoint { lat: number; lng: number }

interface Business {
  id: ID; name: string; category: string; location: GeoPoint;
  valueTags: ID[];          // matched against group requests
  inNetwork: boolean;       // Lotivity business partner
  positiveVotes7d: number;
}

interface Event {
  id: ID; title: string; hostId: ID; hostType: 'user' | 'group' | 'business';
  category: 'sports' | 'paid' | 'volunteer' | 'social' | 'work';
  location: GeoPoint; venueId?: ID;
  startsAt: string; endsAt: string;
  interestTags: ID[]; heritageTags: ID[]; cultureTags: ID[];
  generationTags: Generation[];
  attendeeIds: ID[]; interestedIds: ID[];
  requiresGuardian: boolean;    // true when youth accounts may attend
  sponsoredBy?: ID;
}

interface Group {
  id: ID; name: string; category: Event['category'];
  memberIds: ID[]; radiusMi: number; center: GeoPoint;
  sponsorship: { state: 'none' | 'pending' | 'sponsored'; businessId?: ID; promoCode?: string };
}

interface ActivityRequest {
  id: ID; authorId: ID; description: string;
  radiusMi: number; center: GeoPoint;
  targetInterests: ID[]; targetCulture: ID[]; targetGenerations: Generation[];
  notifiedCount: number;        // simulated
  upvotes: number; upvoteThreshold: number;
  resolvedGroupId?: ID;
}

interface Post {
  id: ID; authorId: ID; eventId?: ID; businessId?: ID;
  body: string; media: MediaRef[];
  voiceMemo?: { blobKey: string; durationSec: number; sentiment: 'positive' | 'neutral' | 'negative' };
  createdAt: string;
  visibleUntil: string;         // enforces the 7-day event-post window
}

interface Connection {
  userId: ID; peerId: ID;
  origin: 'invite' | 'contacts' | 'shared-event';
  sharedEventId?: ID;
  connectedAt: string;
}
```

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
| NFR-1 | Lighthouse PWA audit passes; Performance ≥ 90 on a simulated mid-tier mobile device |
| NFR-2 | First Contentful Paint < 1.5 s on a warm cache |
| NFR-3 | Intro sequence sustains 60 fps on a 2020-or-newer mid-range phone |
| NFR-4 | Initial JS bundle ≤ 300 KB gzipped, excluding the lazily-loaded map |
| NFR-5 | Map view code-split and loaded on first navigation to the Map tab |
| NFR-6 | WCAG 2.1 AA: contrast, focus order, labeled controls, `prefers-reduced-motion` respected |
| NFR-7 | Fully operable with a screen reader; bubble multi-selects expose proper roles and state |
| NFR-8 | No crash-on-refresh at any point in the onboarding flow |
| NFR-9 | Works offline after first load, including the map at previously-viewed zoom levels |
| NFR-10 | No secrets, keys, or real personal data in the repository |

---

## 8. Architecture

```
src/
  app/            # routing, layout shells, providers
  features/
    intro/        # animated zoom sequence
    onboarding/   # profile creation steps
    foryou/
    groups/       # groups + activity requests
    work/
    social/       # feed, recaps, voice memos, network
    map/          # MapLibre view, filters, radius
    profile/
  data/
    fixtures/     # seed JSON, one file per entity
    repo/         # repository layer — the future API seam
    schema/       # shared TypeScript types
  lib/
    recommend/    # scoring engine
    geo/          # distance, radius, bounds
    audio/        # MediaRecorder wrapper
  ui/             # design-system primitives (Bubble, Card, Sheet, Tabs)
```

**The repository layer is the seam.** Every feature reads and writes through `data/repo/*`, which returns Promises and never exposes fixtures directly. Swapping mock for live becomes a change to one directory.

---

## 9. Backend Readiness

v0 ships no backend, but must not foreclose one:

- **BR-1** — Repository functions are async and typed exactly as a future API would return.
- **BR-2** — Entity IDs are opaque strings, never array indices.
- **BR-3** — All timestamps are ISO 8601 UTC.
- **BR-4** — Geospatial queries are isolated in `lib/geo` so they can move to PostGIS unchanged in behavior.
- **BR-5** — Privacy rules (DOB hidden, radius-gated connections, 7-day post visibility) are enforced in the repository layer, not in components — so they survive the migration to a real server.

---

## 10. Testing

| Level | Coverage |
| --- | --- |
| Unit (Vitest) | Recommendation scoring, generation derivation, geo/radius math, promo-code generation, post-visibility windows |
| Component (RTL) | Bubble multi-select behavior, the 6-interest gate, back-navigation without data loss |
| E2E (Playwright) | **(a)** intro → full onboarding → For You; **(b)** create radius request → upvote past threshold → sponsored with promo code; **(c)** map radius + filter change updates pins and count |
| Manual | Install-to-home-screen on iOS Safari and Android Chrome; offline reload; reduced-motion intro |

---

## 11. Milestones

| # | Deliverable | Exit criteria |
| --- | --- | --- |
| M0 | Project scaffold | Vite + TS + Tailwind + PWA manifest; installs and runs offline |
| M1 | Design system + fixtures | UI primitives built; seed data at target volume, types enforced |
| M2 | Onboarding | FR-PROF-1 → 14 complete and persistent |
| M3 | Intro sequence | FR-INTRO-1 → 7, hitting NFR-3 |
| M4 | For You + recommendation engine | FR-FEED and FR-REC complete with unit tests |
| M5 | Groups, requests, sponsorship | FR-GROUP and FR-WORK complete |
| M6 | Social feed + voice memos | FR-SOCIAL complete, including the 7-day window |
| M7 | Map radius | FR-MAP complete, code-split |
| M8 | Polish + audit | All NFRs met; E2E suite green; demo script written |

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
