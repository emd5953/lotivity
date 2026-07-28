# Lotivity — Product Requirements Document

**Version:** 0.1
**Status:** Draft
**Last updated:** 2026-07-28
**Related:** [README](../README.md) · [Technical Requirements](./TECHNICAL_REQUIREMENTS.md)

---

## 1. Problem & Mission

> Replacing artificial exchanges with real experiences. It's not revolutionary — it's real intelligence.

### The problem

Finding something real to do near you is worse than it should be, and it's worse in a specific way: the tools that exist optimize for scroll, not attendance.

- **Event platforms are undifferentiated.** A listing feed shows you what's nearby, not what's *for you*. A 68-year-old retiree and a 24-year-old see the same results, sorted by date or paid placement.
- **Social platforms replaced gathering with watching.** The dominant apps monetize time-on-app, which structurally competes with the user leaving the house.
- **Cultural and faith communities organize offline, invisibly.** People who share heritage, language, or faith already gather constantly — but that activity is coordinated in group chats and church basements, illegible to anyone not already inside it.
- **Local businesses can't reach groups, only individuals.** A coffee shop would happily host a twelve-person book club on a slow Tuesday. There is no mechanism to make that meeting happen.

### The thesis

Matching people on **heritage, generation, faith, and interest** — then constraining everything to a real, walkable radius — produces better recommendations than a generic events feed, because those signals predict who will actually show up.

The second half of the thesis: an app whose revenue is recycled into *funding the gatherings it recommends* is structurally aligned with its users in a way an ad-funded feed is not. We monetize attendance, not attention.

### What we're not

Not a dating app. Not a Facebook Events clone. Not a social network where the feed is the product — the feed exists to document things that happened in person, and it expires.

---

## 2. Target Users

### Consumers

Three account types, chosen by the user during onboarding with a stated incentive to choose accurately (community promotions are matched to the category):

| Segment | Motivation | Constraint | What they need first |
| --- | --- | --- | --- |
| **Youth** | Find peers, activities parents will approve of | Requires a verified community-appointed host or parent for any hosted event or meetup | Safety legible to a guardian |
| **General Adult** | New to a city, new life stage, or wants to rebuild a local social life | Time-poor, skeptical of another app | Something worth attending within a week |
| **Retired** | Structured, recurring, daytime social contact | Lower tolerance for app friction; may be new to PWAs | Recurring groups, not one-off events |

**Cross-cutting segments** that cut across all three and drive the strongest early matching:

- **Heritage communities** — people who selected a heritage during onboarding and want their culture reflected locally.
- **Faith communities** — already gather on a schedule; the highest-intent group in the product.
- **Workplace organizers** — the person who plans the team happy hour. One organizer brings a dozen users.

### Business customers

The paying side. Initial focus: **venues with underused capacity** — coffee shops, restaurants on slow nights, studios, gyms, event spaces. They buy a marketing subscription to list programs and to be matched with organized groups.

Their alternative today is discounting to strangers. Ours delivers a pre-assembled group of twelve people with a shared reason to be there.

---

## 3. The Cold-Start Problem

**A radius-based social app is worthless in an empty radius.** This is the single largest risk to the product, and it dictates launch strategy.

### Strategy: one metro, seeded through groups that already gather

1. **Launch a single metro area.** Density beats coverage. A user in a city with 40 nearby activities has a product; a user in a city with 3 does not.
2. **Recruit through existing communities, not individuals.** Faith congregations, cultural associations, run clubs, and alumni groups arrive pre-assembled. One organizer onboards thirty people who already know each other.
3. **Sign venues before users need them.** The sponsorship loop (§5.2) is the differentiated experience, and it fails visibly if no in-network business exists to match. Target ~15 partner venues before opening the metro.
4. **Seed the calendar.** The first weeks require Lotivity-hosted or Lotivity-sponsored events so the map is never empty on day one.

### Implication for the MVP

The mock MVP must demonstrate what a **dense, working radius feels like** — that is why the demo seeds 40+ events across real neighborhoods. A sparse demo would be an accurate depiction of week one and a useless depiction of the product.

---

## 4. Business Model

### Revenue

**Business marketing subscription — the first and only revenue line at launch.** Businesses pay a recurring fee to:

- List programs and events on the app
- Appear in the in-network pool eligible for group matching
- Access aggregate demand signal (what groups are forming nearby, and what they're asking for)

Deferred: promoted placement, ticketing/booking fees, enterprise plans for the Work tab.

### The reinvestment loop

A defined portion of app advertising budget is spent as **group promo codes** rather than impressions. When a group is sponsored, the discount their members receive is funded by us.

This is the mission claim made operational: *"an app that invests in what its mission is."*

**What it costs:** margin per sponsored gathering, and complexity — subsidy needs a cap, a threshold, and abuse controls. **What it buys:** the acquisition channel *is* the product experience. A sponsored gathering produces attendees, reviews, business proof of ROI, and social recaps that recruit the next group.

### Unit economics to validate (not yet modeled)

- Cost per sponsored gathering vs. users acquired and retained by it
- Business subscription retention against measurable footfall delivered
- Ratio of organic to subsidized gatherings over time — **this must trend toward organic**, or the model is buying activity rather than building it

---

## 5. Core User Journeys

### 5.1 Discover → Attend → Review → Connect

The primary loop.

1. **Discover** — For You surfaces an activity matched on interest, heritage, faith, generation, and proximity. The card states *why* it surfaced.
2. **Attend** — the user marks interest or attends. Attendance is what unlocks everything downstream.
3. **Review** — the user records a **voice memo review**, earning a discount. Voice is deliberate: it's harder to fake than a star rating, faster than typing, and carries tone that makes the recap worth watching.
4. **Connect** — attendees may connect, but only inside the radius and only via invite, contact match, or a shared event. Event posts stay visible for 7 days to people who attended or were interested, then expire.

**Why the 7-day expiry matters:** it makes the feed a record of real gatherings rather than accumulating content. If a post outlives the memory of the event, the feed becomes the product — which is the thing we're replacing.

### 5.2 Request → Match → Sponsor

The differentiated loop, and the one that produces the story worth telling.

1. **Request** — a user posts a radius request: *"Christian group looking for a place to meet."*
2. **Notify** — users in radius matching the targeted faith, culture, and generation are notified of the forming interest.
3. **Upvote** — the request accumulates community support. A threshold converts interest into commitment.
4. **Match** — Lotivity matches the group to an in-network business with aligned values — a coffee shop with slow Tuesdays.
5. **Sponsor** — a time is set and a promo code is issued (`lotivityclubchrist`), funded from advertising budget.
6. **Prove** — attendance, reviews, and recaps feed back as conversion metrics for the business and social proof for the next group.

This loop is the reason the app exists. Everything else is table stakes.

### 5.3 Work

An organizer proposes an activity; colleagues vote; the winner is booked. Companies can pre-purchase activity bundles. Same sponsorship mechanics, different social graph — and the fastest path to onboarding thirty users at once.

---

## 6. Feature Priorities

Reconciled with the TRD's nine milestones so the two documents agree on order.

### P0 — the product doesn't exist without these

| Feature | Why | TRD |
| --- | --- | --- |
| Profile creation with heritage, faith, generation, interests | Every match depends on this data | M2 |
| For You ranked feed with visible reasoning | The core value proposition, demonstrated in one screen | M4 |
| Map radius with filters | Proves locality; the strongest "this is about *here*" signal | M7 |
| Activity requests → sponsorship | The differentiated loop (§5.2) | M5 |

### P1 — required for the loop to close

| Feature | Why | TRD |
| --- | --- | --- |
| Groups and clubs | Turns one-off attendance into recurring membership | M5 |
| Social feed with 7-day recaps | Retention and proof; makes attendance visible | M6 |
| Voice-memo reviews | Trust signal and the discount mechanic | M6 |
| Network / connections | Radius-gated social graph | M6 |
| Business portal | The paying side needs self-service | Not yet specified |

### P2 — after product-market fit signal

Intro sequence (M3) · Work tab depth · Artist following · Multi-metro expansion · Youth ID verification at scale · Native apps

### Rationale for MVP scope

The mock MVP builds **P0 minus sponsorship**: onboarding, For You, and the map. Reason: those three prove *"this app knows who I am and what's actually near me"* — the claim everything else rests on. The sponsorship loop is more compelling but depends on group infrastructure, and a demo of sponsorship without a populated, personalized feed underneath it would be a demo of a coupon.

---

## 7. Success Metrics

### Real-world (post-launch)

**North star: gatherings attended per active user per month.** Not sessions, not time-in-app — attendance. Every other metric is diagnostic.

| Metric | Why it matters | Direction |
| --- | --- | --- |
| Interested → attended conversion | Whether recommendations produce real-world action | The core quality signal |
| Review rate (voice memos per attendance) | Content supply and trust signal | Reviews fund the discount mechanic |
| Repeat attendance within 30 days | Whether the first experience was good enough to repeat | Retention proxy |
| Requests reaching sponsorship | Health of the differentiated loop | Should rise as venue density grows |
| Business subscription retention | Whether we deliver measurable footfall | The revenue truth |
| Organic : sponsored gathering ratio | Whether the community sustains itself | **Must trend organic** |
| Time-in-app | Deliberately *not* a growth target | Flat or down is acceptable |

### Mock MVP (a different bar entirely)

The MVP is a demo. It cannot measure retention. It succeeds if a person unfamiliar with the concept can:

1. Complete onboarding without confusion or instruction
2. Look at For You and recognize their own answers reflected in it — the "why you're seeing this" line lands
3. Change the map radius and see the neighborhood change meaningfully
4. Articulate what Lotivity does, unprompted, after five minutes

That last one is the real test.

---

## 8. Trust, Safety & Privacy Principles

Product commitments, not implementation details. The TRD encodes these as `BR-5` — enforced in the data layer so they survive the move to a real backend.

1. **Date of birth is never shown to other users.** Only the derived generation label is. Age enables targeting and harassment; generation enables matching. We collect the first to compute the second.
2. **Youth accounts require a verified adult.** Any event a youth account hosts or attends requires a community-appointed host or parent with ID verification. Non-negotiable, and a launch blocker for youth accounts specifically.
3. **Connections are radius-gated.** You may only connect with someone in your radius, via invite, contact match, or a shared event. There is no open discovery of strangers — the product is local by construction, and this is a safety property as much as a design one.
4. **Event posts expire after 7 days,** visible only to people who attended or expressed interest. The feed is a record, not an archive.
5. **Self-declared identity is never verified.** Heritage, faith, and culture selections drive matching and are never treated as credentials or shared as attributes of record.
6. **Reviews are attributable.** Voice memos carry the reviewer's identity to their network. Anonymous reviews are a spam vector and a trust sink.

---

## 9. Resolved Product Decisions

### 9.1 Faith and community are tagged separately, shown together

The README lists religion/culture as one bubble set: *black, jewish, christian, latin, arab, muslim, hindi*. That mixes ethnicity with religion, and the two behave differently in matching — a Bible-study request should target faith regardless of ethnicity, while a Colombian happy hour targets heritage.

**Decision:** tag them in separate namespaces (`faith:christian`, `community:latin`) while presenting them on a **single onboarding screen**, exactly as the README describes.

**Why:** preserves matching precision without adding an onboarding step. The UI can split into two screens later without a data migration; merging two namespaces after the fact is far harder than never conflating them.

**"Hindi" is corrected to "Hindu"** in the faith list. Hindi is a language, already collected in the separate Languages step.

Note that heritage (§ onboarding step 4) remains a third, distinct axis — nationality-level and continent-grouped. Three axes: heritage, faith, community.

### 9.2 Both faith and community selections are optional

Skippable without penalty, per FR-PROF-9. Requiring a faith declaration to use a local activities app is both a privacy problem and an adoption barrier. Matching degrades gracefully — interest and proximity carry the feed alone.

### 9.3 Guest profiles get full read access, no write

Guests browse For You, the map, and public groups. They cannot attend, review, connect, or request. **Why:** the cold-start problem means we need people to see a populated radius before committing. Requiring signup to see whether anything is happening nearby is the fastest way to lose someone in a city we just launched in.

### 9.4 Generation is shown; age is not

Generation is displayed as a bubble beside the name (FR-PROF-3). It's a matching signal and an identity people claim comfortably, unlike an age number.

### 9.5 The MVP demo seeds New York City

Real coordinates and neighborhoods, **fictional venue names**. Real venue names would imply partnerships that don't exist.

---

## 10. Open Questions

| # | Question | Needed by |
| --- | --- | --- |
| 1 | What upvote threshold triggers sponsorship, and does it scale with radius population? | Before M5 (Groups) |
| 2 | Are voice-memo reviews visible to the whole radius, or only the reviewer's network? | Before M6 (Social) |
| 3 | What is the per-gathering subsidy cap, and who approves exceptions? | Before first real sponsorship |
| 4 | Which metro launches first, and do we have ~15 venues willing to sign there? | Before launch planning |
| 5 | How is a business's "values alignment" determined — self-declared, vetted, or community-rated? | Before M5; it's a trust surface |
| 6 | What is the youth ID verification vendor and cost per verification? | Before youth accounts ship |
| 7 | Does the intro sequence use hand-drawn illustration or generated/vector art? | Before M3 |
| 8 | What happens when a sponsored gathering has poor attendance — does the business get made whole? | Before first real sponsorship |

---

## 11. Non-Goals

Explicitly out of scope, to keep the product from drifting:

- **Dating or romantic matching.** Relationship status informs activity relevance, nothing more.
- **A general-purpose social network.** No follower counts, no permanent profiles-as-feeds, no content beyond real gatherings.
- **National coverage before metro density.** Breadth without density produces empty radii, which is a worse product than no product.
- **Engagement maximization.** Time-in-app is not a target and is not optimized for.
- **Verifying identity claims.** Heritage and faith are self-declared and stay that way.
