# LOTIVITY · DESIGN SPECIFICATION

A replication prompt. Follow this and the result is indistinguishable from
Lotivity.

## WHAT LOTIVITY IS

A local-activity app you actually leave the house for. It matches people to
real gatherings in their radius by generation, heritage, faith, and interest,
and it shows its work on every card. Surfaces: the PWA (React + Vite +
Tailwind) — onboarding, For You, Groups, Social, Map, Profile.

## THE ONE-LINE DESIGN THESIS

"Cinema black, one olive accent, zero clutter." The window is a dark room.
The content — the event, the map, the person — is the only bright object.
Structure comes from luminance steps, not borders. Olive appears ONLY where
something is alive. Cream appears exactly once per screen, at the payoff.

## EDITORIAL VOICE

1. **Dark only.** There is no light mode. The base is pure black.
2. **Micro-labels are LOWERCASE**, mono, positively letterspaced. Lotivity
   whispers "sponsored", it does not shout SPONSORED.
3. **Headlines are tight.** Inter Tight with aggressively negative tracking.

These are deliberate. Do not "fix" them back toward a conventional light
mobile app.

---

## 1 · COLOR SYSTEM

### 1.1 BRAND SWATCHES

| Token       | Hex       | Use                                             |
| ----------- | --------- | ----------------------------------------------- |
| `accent`    | `#A8C152` | olive. Selection, active tab, live state, focus. |
| `accent-hi` | `#BED56F` |                                                 |
| `accent-lo` | `#8FA847` |                                                 |
| `cream`     | `#F1ECE5` | body text, the single payoff fill               |
| `ink`       | `#0A0A0A` | text on cream                                   |
| `teal`      | `#7B9AAB` | resting, waiting, informational                 |
| `error`     | `#DC2626` |                                                 |
| `success`   | `#16A34A` |                                                 |

Olive never carries a paragraph.

### 1.2 SURFACES

| Token     | Hex       | Use                                    |
| --------- | --------- | -------------------------------------- |
| `bg`      | `#000000` | the app base, a dark room              |
| `soft`    | `#0E0E0E` | tab bar, sheets, barely lifted         |
| `raised`  | `#191918` | inputs, chips, hovers, card floor      |
| `raised2` | `#232322` | card ceiling (the surface-lift only)   |

### 1.3 FOREGROUND RAMP

Built from cream, never from pure white:

```
fg    #F1ECE5           cream/85  cream/60  cream/45  cream/30  cream/20
```

### 1.4 STRUCTURE BY LUMINANCE, NOT BORDERS

```
laneA   cream @ 0.035     alternating list fill
laneB   cream @ 0.022
border        cream @ 0.12
borderStrong  cream @ 0.20
borderFaint   cream @ 0.06
hairline      cream @ 0.09
```

**THE RULE:** reach for a luminance step or an INSET ring before you reach for
a border. A feed of 18 event cards separated by hairlines reads as a
spreadsheet. The same feed separated by a raised fill and an inset ring reads
as a product.

Inset rings never shift layout between states. Outer borders do. Use inset.

### 1.5 CATEGORICAL PALETTE

For map pins, club categories, and any other categorical encoding. Muted and
desaturated on purpose so a fully-populated map still reads as Lotivity and
never as a fruit salad.

```
sand   #C9B08A     plum   #9B7FA6     slate  #8892A0
moss   #7E8F5A     clay   #A6766B     teal   #7B9AAB
```

**HOUSE RULE: no orange in this list, ever.**

Olive is not in this list either — it is reserved for aliveness, not for
categories.

### 1.6 COLOR LAWS

a) **Olive means alive.** Active tab, selected bubble, focus ring, the
   progress a user has made. If it is static and inert, it is not olive.
b) **Cream is the payoff.** The primary button fill and the body text color.
   Nothing else.
c) **No gradients as decoration.** The only gradient allowed is the card
   surface lift (`raised2` → `raised`).
d) **Never pure white.** Cream, or the cream opacity ramp.

---

## 2 · TYPOGRAPHY

### 2.1 FAMILIES

```
Display   Inter Tight  (fallback Inter, system-ui)
Body      Inter        (fallback system-ui, -apple-system)
Mono      JetBrains Mono (fallback SF Mono, Menlo)
```

### 2.2 SCALE

| Role       | Spec                                                        |
| ---------- | ----------------------------------------------------------- |
| screen h1  | Inter Tight 600, 30px, tracking -0.04em, cream              |
| section h2 | Inter Tight 600, 20px, tracking -0.03em                     |
| card title | Inter Tight 600, 17px, tracking -0.02em                     |
| body       | Inter 400, 15px, line-height 1.55, cream/85                 |
| secondary  | Inter 400, 14px, cream/45                                   |
| eyebrow    | mono 500, 11px, letter-spacing 0.08em, LOWERCASE, cream/30  |
| chip       | mono 500, 10.5px, letter-spacing 0.06em, LOWERCASE          |
| numeral    | mono, tabular-nums — counts, distances, radii, prices       |

### 2.3 THE TYPOGRAPHIC TELLS

- Headline tracking is NEGATIVE and aggressive (-0.03 to -0.045em). Display
  type should feel packed.
- Every non-headline label is mono, lowercase, letterspaced POSITIVE. The
  tension between tight display and airy mono chrome is the look.
- Lowercase is applied with CSS `text-transform`, never by rewriting the
  string — assistive tech and tests still read the real words.
- **"Lotivity" itself stays capitalized** in brand moments (the wordmark, the
  entry screen). It goes lowercase only inside mono chrome.

---

## 3 · LAYOUT

### 3.1 THE FRAME

A single centered column, `max-width: 30rem`, `min-height: 100dvh`, black to
the edges. A fixed tab bar at the bottom on `soft` with one hairline above it,
respecting `env(safe-area-inset-bottom)`.

### 3.2 CHROME ONLY WHEN IT HAS SOMETHING TO SAY

No decorative headers, no toolbar bands, no badges that count nothing. The
stepper appears only during onboarding steps. The guest notice appears only
for guests.

### 3.3 MOTION

| Surface           | Duration                                     |
| ----------------- | -------------------------------------------- |
| hover / press     | 0.16s                                        |
| selection change  | 0.18s ease-in-out                            |
| card entrance     | 0.25s ease-out                               |
| sheet             | 0.22s                                        |

Smaller elements move faster. `prefers-reduced-motion: reduce` disables every
loop animation, and the app must be fully usable static.

**No audio-reactive motion.** No waveforms, no decibel meters, no bars that
bounce to sound. Lotivity is about being somewhere, not about listening to a
level.

---

## 4 · SURFACES

### 4.1 FOR YOU (the feed)

The hero surface. Event cards on `raised` with an inset ring at cream/7,
radius 16. Card anatomy top to bottom:

1. eyebrow — mono lowercase date · time, cream/30
2. title — Inter Tight 600, tight tracking, cream
3. place — neighborhood · distance, mono numerals, cream/45
4. chips — price, going count, guardian requirement
5. the reason row — separated by a luminance step, not a rule: **why this card
   is here**, in cream/45.

The reason row is load-bearing. A card that cannot explain itself does not
ship.

Sponsored is a chip in teal, never olive — a sponsor is not the user's own
aliveness.

### 4.2 MAP

Dark basemap (Carto dark-matter). Pins are 14px dots in the categorical
palette with a 2px ink ring so they separate from each other. The radius
control is olive-accented; the radius value is mono tabular. The selected pin
opens a sheet on `soft`.

### 4.3 ONBOARDING

One question per screen. The stepper is a row of 1px olive segments —
progress is alive, so progress is olive. Bubbles are the signature control:
pill-shaped, `raised` fill, inset ring at cream/12, and when selected an olive
fill with ink text. Real ARIA `checkbox`/`radio` states, always.

### 4.4 PROFILE

Grouped cards. Every group is a mono lowercase eyebrow plus a wrap of chips.
The privacy promise ("your date of birth is never shown") is body copy in
cream/85, not fine print in cream/30.

---

## 5 · PILL SYSTEM

```
.pill         inline-flex, radius 999px, weight 600,
              transition transform 0.16s, opacity 0.16s
              hover scale(1.03) · active scale(0.98)
.pill-cream   cream bg, ink text            — the one payoff action
.pill-ghost   inset 0 0 0 1px cream@0.22, cream text
              hover raises the inset ring to cream@0.45
.pill-quiet   no fill, cream/45 text, hover cream
```

Ghost buttons use an INSET box-shadow, not a border, so the pill's size never
shifts between states.

Exactly one `.pill-cream` per screen. If a screen wants two, one of them is
not the payoff.

---

## 6 · ATMOSPHERE

**Film grain** over everything: a fixed full-viewport pseudo-element,
`pointer-events: none`, `opacity: 0.045`, `mix-blend-mode: screen`, an inline
SVG `feTurbulence` fractalNoise at `baseFrequency 0.85`, `numOctaves 2`. One
atmosphere, whole app. It is what keeps a pure-black UI from looking like a
dead LCD.

**Selection**: olive background, ink text.
**Focus-visible**: 2px olive outline, offset 2px. Pointer users see no change;
keyboard users always see where they are.

---

## 7 · COPY VOICE

Positioning line: "Local Activities. At a Price Best for You."

- Headlines are short and human: "Around you", "Hey, Rosa".
- Prompts and labels are lowercase and casual.
- Results are always specific and numeric: "14 going · 0.4 mi",
  "8 people with Colombian heritage voted it a positive experience".
- Never say "AI-powered", "seamless", "effortless", or "revolutionize". The
  README already commits to this: *"It's not revolutionary — it's real
  intelligence."* State what happened, with a number.

---

## 8 · CHECKLIST FOR A NEW LOTIVITY SURFACE

- [ ] Background is black or `soft`; no light mode anywhere
- [ ] Separation is a luminance step or an INSET ring, not an outer border
- [ ] Olive appears only where something is alive or selected
- [ ] At most one cream payoff moment per screen
- [ ] Micro-labels are mono, LOWERCASE via CSS, positively letterspaced
- [ ] Headlines are Inter Tight with negative tracking
- [ ] No orange, anywhere, including categorical pins
- [ ] Numbers are mono and tabular
- [ ] No audio-reactive or decibel-style animation
- [ ] `prefers-reduced-motion` disables every loop animation

---

## 9 · OPEN ITERATIONS

Tracked deliberately, not accidental debt:

- **Palette.** Olive/cream/ink is the v1 starting point inherited wholesale.
  The token layer (`src/index.css` custom properties) is the only place the
  palette lives, so a full re-hue is a single-file change. Component classes
  never hardcode a hex.
