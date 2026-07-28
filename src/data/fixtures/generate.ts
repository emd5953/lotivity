import type {
  ActivityRequest,
  Business,
  Connection,
  EventCategory,
  Generation,
  GeoPoint,
  Group,
  LotivityEvent,
  Post,
  User,
} from '@/data/schema';
import { HERITAGES } from '@/data/reference/heritage';
import { COMMUNITY_TAGS, FAITH_TAGS, LANGUAGES } from '@/data/reference/culture';
import { INTERESTS } from '@/data/reference/interests';
import { NEIGHBORHOODS } from '@/data/reference/nyc';
import { generationFromDob } from '@/lib/generation';
import { offsetPoint } from '@/lib/geo';
import { createRng, type Rng } from './rng';
import {
  CAFE_SUFFIXES,
  EVENT_TITLE_TEMPLATES,
  FIRST_NAMES,
  GROUP_NAME_TEMPLATES,
  LAST_NAMES,
  POST_BODIES,
  REQUEST_TEMPLATES,
  RESTAURANT_SUFFIXES,
  STUDIO_SUFFIXES,
  VENUE_PREFIXES,
  VENUE_SUFFIXES,
} from './pools';

export const SEED = 20260728;

/**
 * Timestamps are generated relative to a fixed anchor rather than "now", so a
 * demo run months from now still shows a plausible mix of past and future.
 * The repo layer rebases these onto the current date at read time.
 */
export const ANCHOR = new Date('2026-07-28T12:00:00.000Z');

const VOLUMES = {
  users: 64,
  businesses: 26,
  events: 44,
  groups: 14,
  requests: 9,
  posts: 84,
} as const;

const DAY_MS = 86_400_000;

const iso = (d: Date) => d.toISOString();
const shiftDays = (base: Date, days: number) => new Date(base.getTime() + days * DAY_MS);
const shiftHours = (base: Date, hours: number) => new Date(base.getTime() + hours * 3_600_000);

/** Hours people actually gather, in New York local time. */
const EVENT_HOURS_ET = [7, 8, 9, 10, 11, 12, 13, 17, 18, 19, 20];
const MORNING_HOURS_ET = [7, 8, 9, 10];
const EVENING_HOURS_ET = [17, 18, 19, 20];
const ET_UTC_OFFSET = 4; // EDT; the fixture world is a single summer metro.

/**
 * A title that says "night" scheduled at 9 a.m. reads as broken, so titles
 * naming a time of day constrain the hours they can be scheduled at.
 */
function hoursForTitle(title: string): number[] {
  const t = title.toLowerCase();
  if (/night|evening|open mic|happy hour|sunset|showcase|social\b/.test(t)) return EVENING_HOURS_ET;
  if (/morning|sunrise|breakfast|commute/.test(t)) return MORNING_HOURS_ET;
  if (/afternoon/.test(t)) return [13, 14, 15];
  return EVENT_HOURS_ET;
}

/** Pins a date to a plausible local hour rather than an arbitrary offset. */
function atLocalHour(day: Date, hourEt: number, minutes: number): Date {
  return new Date(
    Date.UTC(
      day.getUTCFullYear(),
      day.getUTCMonth(),
      day.getUTCDate(),
      hourEt + ET_UTC_OFFSET,
      minutes,
    ),
  );
}

/** Scatter a point up to ~0.4 mi from a neighborhood center. */
function jitter(rng: Rng, center: GeoPoint): GeoPoint {
  return offsetPoint(center, rng.float(-0.4, 0.4), rng.float(-0.4, 0.4));
}

function dobForGeneration(rng: Rng, gen: Generation): string {
  const ranges: Record<Generation, [number, number]> = {
    alpha: [2013, 2016],
    genz: [1997, 2008],
    millennial: [1981, 1996],
    genx: [1965, 1980],
    boomer: [1946, 1964],
    silent: [1938, 1945],
  };
  const [from, to] = ranges[gen];
  const year = rng.int(from, to);
  const month = String(rng.int(1, 12)).padStart(2, '0');
  const day = String(rng.int(1, 28)).padStart(2, '0');
  return `${year}-${month}-${day}`;
}

function makeUsers(rng: Rng): User[] {
  // Weighted so adults dominate but every segment is represented (PRD §2).
  const generationPool: Generation[] = [
    ...Array<Generation>(4).fill('genz'),
    ...Array<Generation>(7).fill('millennial'),
    ...Array<Generation>(4).fill('genx'),
    ...Array<Generation>(3).fill('boomer'),
    'silent',
    'alpha',
  ];

  return Array.from({ length: VOLUMES.users }, (_, i) => {
    const generation = rng.pick(generationPool);
    const dob = dobForGeneration(rng, generation);
    const hood = rng.pick(NEIGHBORHOODS);
    const accountType =
      generation === 'alpha' ? 'youth' : generation === 'silent' || (generation === 'boomer' && rng.chance(0.55)) ? 'retired' : 'adult';

    const interests = rng.sample(INTERESTS, 6);

    return {
      id: `user:${i + 1}`,
      name: `${rng.pick(FIRST_NAMES)} ${rng.pick(LAST_NAMES)}`,
      dob,
      generation: generationFromDob(dob),
      accountType,
      heritage: rng.sample(HERITAGES, rng.int(1, 2)).map((h) => h.id),
      languages: ['English', ...rng.sample(LANGUAGES.filter((l) => l !== 'English'), rng.int(0, 2))],
      cultureTags: [
        ...(rng.chance(0.6) ? [rng.pick(FAITH_TAGS).id] : []),
        ...rng.sample(COMMUNITY_TAGS, rng.int(0, 2)).map((t) => t.id),
      ],
      interests: interests.map((i2) => i2.id),
      interestSubcategories: interests
        .filter(() => rng.chance(0.5))
        .map((i2) => rng.pick(i2.subcategories).id),
      location: jitter(rng, hood.center),
      isGuest: false,
      ...(accountType === 'youth'
        ? { youthVerification: { status: 'verified' as const, guardianName: 'Community host' } }
        : {}),
    } satisfies User;
  });
}

function makeBusinesses(rng: Rng): Business[] {
  return Array.from({ length: VOLUMES.businesses }, (_, i) => {
    const hood = rng.pick(NEIGHBORHOODS);
    const isFood = rng.chance(0.6);
    const suffix = isFood
      ? rng.pick(rng.chance(0.5) ? CAFE_SUFFIXES : RESTAURANT_SUFFIXES)
      : rng.pick(rng.chance(0.5) ? STUDIO_SUFFIXES : VENUE_SUFFIXES);

    return {
      id: `biz:${i + 1}`,
      name: `${rng.pick(VENUE_PREFIXES)} ${suffix}`,
      category: isFood ? rng.pick(['Coffee shop', 'Restaurant', 'Bakery']) : rng.pick(['Studio', 'Event space', 'Community hall']),
      mapFilter: isFood ? 'food' : 'workshops',
      location: jitter(rng, hood.center),
      neighborhood: hood.name,
      valueTags: [
        ...(rng.chance(0.4) ? [rng.pick(FAITH_TAGS).id] : []),
        ...rng.sample(COMMUNITY_TAGS, rng.int(0, 2)).map((t) => t.id),
      ],
      // ~15 in network, per the PRD launch target.
      inNetwork: i < 15,
      positiveVotes7d: rng.int(3, 92),
    } satisfies Business;
  });
}

function makeEvents(rng: Rng, users: User[], businesses: Business[]): LotivityEvent[] {
  const categories: EventCategory[] = ['social', 'sports', 'volunteer', 'paid', 'work'];

  return Array.from({ length: VOLUMES.events }, (_, i) => {
    const hood = rng.pick(NEIGHBORHOODS);
    const interest = rng.pick(INTERESTS);
    const venue = rng.pick(businesses);
    const templates = EVENT_TITLE_TEMPLATES[interest.id] ?? ['{neighborhood} meetup'];
    const title = rng
      .pick(templates)
      .replace('{neighborhood}', hood.name)
      .replace('{place}', venue.name);

    // Roughly a third in the past so recaps and 7-day windows have material.
    const dayOffset = i % 3 === 0 ? rng.int(-13, -1) : rng.int(0, 21);
    const startsAt = atLocalHour(
      shiftDays(ANCHOR, dayOffset),
      rng.pick(hoursForTitle(title)),
      rng.pick([0, 30]),
    );
    const attendees = rng.sample(users, rng.int(4, 22)).map((u) => u.id);
    const requiresGuardian = rng.chance(0.18);

    return {
      id: `event:${i + 1}`,
      title,
      hostId: rng.chance(0.5) ? venue.id : rng.pick(users).id,
      hostType: rng.chance(0.5) ? 'business' : 'user',
      category: rng.pick(categories),
      location: jitter(rng, hood.center),
      neighborhood: hood.name,
      venueId: venue.id,
      startsAt: iso(startsAt),
      endsAt: iso(shiftHours(startsAt, rng.int(1, 4))),
      interestTags: [interest.id, ...rng.sample(INTERESTS, rng.int(0, 1)).map((x) => x.id)],
      heritageTags: rng.chance(0.35) ? rng.sample(HERITAGES, 1).map((h) => h.id) : [],
      cultureTags: [
        ...(rng.chance(0.3) ? [rng.pick(FAITH_TAGS).id] : []),
        ...(rng.chance(0.3) ? [rng.pick(COMMUNITY_TAGS).id] : []),
      ],
      generationTags: rng.sample<Generation>(
        ['genz', 'millennial', 'genx', 'boomer', 'silent', 'alpha'],
        rng.int(1, 3),
      ),
      attendeeIds: attendees,
      interestedIds: rng.sample(users, rng.int(3, 18)).map((u) => u.id),
      requiresGuardian,
      ...(rng.chance(0.25) ? { sponsoredBy: rng.pick(businesses.filter((b) => b.inNetwork)).id } : {}),
      ...(rng.chance(0.3) ? { priceLabel: `$${rng.int(5, 30)}` } : {}),
    } satisfies LotivityEvent;
  });
}

function makeGroups(rng: Rng, users: User[], businesses: Business[]): Group[] {
  const inNetwork = businesses.filter((b) => b.inNetwork);

  return Array.from({ length: VOLUMES.groups }, (_, i) => {
    const hood = rng.pick(NEIGHBORHOODS);
    const interest = rng.pick(INTERESTS);
    const name = rng
      .pick(GROUP_NAME_TEMPLATES)
      .replace('{neighborhood}', hood.name)
      .replace('{interest}', interest.label);

    const roll = rng.next();
    const sponsorState = roll < 0.35 ? 'sponsored' : roll < 0.6 ? 'pending' : 'none';
    const sponsor = rng.pick(inNetwork);

    return {
      id: `group:${i + 1}`,
      name,
      category: rng.pick<EventCategory>(['social', 'sports', 'volunteer', 'paid']),
      description: `A ${interest.label.toLowerCase()} group meeting regularly around ${hood.name}.`,
      memberIds: rng.sample(users, rng.int(5, 28)).map((u) => u.id),
      radiusMi: rng.pick([1, 2, 3, 5]),
      center: jitter(rng, hood.center),
      neighborhood: hood.name,
      interestTags: [interest.id],
      cultureTags: rng.chance(0.4) ? [rng.pick([...FAITH_TAGS, ...COMMUNITY_TAGS]).id] : [],
      sponsorship:
        sponsorState === 'sponsored'
          ? {
              state: 'sponsored',
              businessId: sponsor.id,
              promoCode: `lotivity${name.toLowerCase().replace(/[^a-z]/g, '').slice(0, 12)}`,
            }
          : sponsorState === 'pending'
            ? { state: 'pending', businessId: sponsor.id }
            : { state: 'none' },
    } satisfies Group;
  });
}

function makeRequests(rng: Rng, users: User[], groups: Group[]): ActivityRequest[] {
  return Array.from({ length: VOLUMES.requests }, (_, i) => {
    const hood = rng.pick(NEIGHBORHOODS);
    const threshold = rng.pick([25, 40, 50]);
    const upvotes = rng.int(4, Math.round(threshold * 1.3));

    return {
      id: `request:${i + 1}`,
      authorId: rng.pick(users).id,
      description: REQUEST_TEMPLATES[i % REQUEST_TEMPLATES.length] as string,
      radiusMi: rng.pick([1, 2, 3, 5]),
      center: jitter(rng, hood.center),
      targetInterests: rng.sample(INTERESTS, rng.int(1, 2)).map((x) => x.id),
      targetCulture: rng.chance(0.5) ? [rng.pick([...FAITH_TAGS, ...COMMUNITY_TAGS]).id] : [],
      targetGenerations: rng.sample<Generation>(['genz', 'millennial', 'genx', 'boomer'], rng.int(1, 3)),
      notifiedCount: rng.int(40, 480),
      upvotes,
      upvoteThreshold: threshold,
      ...(upvotes >= threshold ? { resolvedGroupId: rng.pick(groups).id } : {}),
    } satisfies ActivityRequest;
  });
}

function makePosts(rng: Rng, users: User[], events: LotivityEvent[], businesses: Business[]): Post[] {
  const pastEvents = events.filter((e) => new Date(e.startsAt) < ANCHOR);

  return Array.from({ length: VOLUMES.posts }, (_, i) => {
    const attachToEvent = rng.chance(0.75) && pastEvents.length > 0;
    const event = rng.pick(pastEvents.length > 0 ? pastEvents : events);
    const createdAt = attachToEvent
      ? shiftHours(new Date(event.endsAt), rng.int(1, 20))
      : shiftDays(ANCHOR, rng.int(-9, -1));

    const hasVoice = rng.chance(0.28);

    return {
      id: `post:${i + 1}`,
      authorId: attachToEvent && event.attendeeIds.length > 0
        ? (event.attendeeIds[rng.int(0, event.attendeeIds.length - 1)] as string)
        : rng.pick(users).id,
      ...(attachToEvent ? { eventId: event.id } : { businessId: rng.pick(businesses).id }),
      body: POST_BODIES[i % POST_BODIES.length] as string,
      media: [],
      ...(hasVoice
        ? {
            voiceMemo: {
              blobKey: `seeded-memo:${i + 1}`,
              durationSec: rng.int(8, 62),
              sentiment: rng.chance(0.82) ? ('positive' as const) : ('neutral' as const),
            },
          }
        : {}),
      createdAt: iso(createdAt),
      // The 7-day window (FR-SOCIAL-2) is baked into the data, not just the UI.
      visibleUntil: iso(shiftDays(createdAt, 7)),
    } satisfies Post;
  });
}

function makeConnections(rng: Rng, users: User[], events: LotivityEvent[]): Connection[] {
  const out: Connection[] = [];
  for (const user of users.slice(0, 30)) {
    for (const peer of rng.sample(users, rng.int(2, 7))) {
      if (peer.id === user.id) continue;
      const origin = rng.pick(['invite', 'contacts', 'shared-event'] as const);
      const event = rng.pick(events);
      out.push({
        userId: user.id,
        peerId: peer.id,
        origin,
        ...(origin === 'shared-event' ? { sharedEventId: event.id } : {}),
        connectedAt: iso(shiftDays(ANCHOR, -rng.int(1, 300))),
      });
    }
  }
  return out;
}

export interface World {
  users: User[];
  businesses: Business[];
  events: LotivityEvent[];
  groups: Group[];
  requests: ActivityRequest[];
  posts: Post[];
  connections: Connection[];
}

/** Builds the entire fixture world. Deterministic for a given seed. */
export function generateWorld(seed: number = SEED): World {
  const rng = createRng(seed);
  const users = makeUsers(rng);
  const businesses = makeBusinesses(rng);
  const events = makeEvents(rng, users, businesses);
  const groups = makeGroups(rng, users, businesses);
  const requests = makeRequests(rng, users, groups);
  const posts = makePosts(rng, users, events, businesses);
  const connections = makeConnections(rng, users, events);

  return { users, businesses, events, groups, requests, posts, connections };
}
