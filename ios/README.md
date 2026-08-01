# Lotivity — iOS

The Lotivity app. Same product, same design system, and the same fixture world
as the React PWA it replaced — see `../docs/PRD.md` and `../docs/DESIGN_SPEC.md`,
which remain the source of truth. `../docs/TECHNICAL_REQUIREMENTS.md` still holds
for the functional requirements and the data model; its stack and file-tree
sections describe the retired web implementation, and this file supersedes them.

## Layout

```
ios/
  LotivityKit/          domain layer as a Swift package — no UI, testable from the CLI
    Sources/LotivityKit/
      Schema.swift        the types features and the repo layer agree on (TRD §5)
      Geo.swift           haversine, radius filtering, proximity scoring
      Generation.swift    DOB → generation, account-type suggestion
      Recommend.swift     the ranking engine and its reasons (TRD §6)
      Reference/          heritage, culture, interests, NYC neighborhoods
      Fixtures/           deterministic PRNG + the world generator
      Repo/               the only way features read data (BR-1)
      Persistence.swift   JSON-per-key on disk, best-effort
    Tests/                the web app's suites, ported to XCTest
  Lotivity/             the app
    Design/               tokens, the pill system, bubbles, film grain
    Features/             ForYou, Map, Profile, Onboarding, placeholders
  Lotivity.xcodeproj
```

## Build and test

```sh
# domain layer — fast, no simulator
cd ios/LotivityKit && swift test

# the app
cd ios && xcodebuild -project Lotivity.xcodeproj -scheme Lotivity \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' build
```

Minimum iOS 17. Swift language mode 5 — the package and app both opt in
explicitly rather than inheriting whatever the toolchain defaults to.

## The fixture world is the world the web app shipped

`LotivityKit`'s PRNG is a bit-for-bit port of the JavaScript `mulberry32`, and
the generator consumes randomness in exactly the same order, so this app builds
the identical world the React version did from the same seed. That was checked
by dumping every field of every record from both and diffing — the dumps were
identical — and the digests are now pinned in `FingerprintTests`, so any
reordered `rng` call fails loudly instead of quietly reshuffling the demo.

To see the full text when that test fails:

```sh
FINGERPRINT_OUT=/tmp/world.txt swift test --filter FingerprintTests
```

## Deliberate differences from the web app

- **MapKit instead of MapLibre.** No third-party dependency and no tile CDN. The
  basemap is Apple's dark style rather than Carto dark-matter, so the map reads
  slightly bluer than the web version. The radius is now drawn as an actual
  circle overlay, which the web app only implied through the viewport.
- **No marketing landing page.** `/landing` is a web entry point for people
  arriving from outside; an installed app has no equivalent surface.
- **Generation is derived from the date string, not a `Date`.** The web version
  parses `yyyy-MM-dd` as an instant and reads the UTC year, which is off by one
  in time zones ahead of UTC. The Swift port reads calendar components, so the
  cohort boundaries hold everywhere.
- **Tab icons are SF Symbols.** Several of the web glyphs (`☺`, `❋`) resolve to
  color emoji on iOS, and a colored icon in a bar that encodes state with olive
  would be lying.
- **Sort ties break explicitly.** Swift's sort is not stable, so every ordering
  in the repo layer carries an id tiebreak. Same output, no reliance on
  incidental behavior.
- **`PublicUser` is its own type.** In TypeScript it was `Omit<User, 'dob'>`;
  here it is a distinct struct, so leaking a date of birth is a compile error
  rather than a code-review catch (BR-5).
