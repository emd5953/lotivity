import type { LotivityEvent, User } from '@/data/schema';
import { distanceMiles, proximityScore } from '@/lib/geo';
import { DEFAULT_FEED_RADIUS_MI, WEIGHTS, type FactorId } from './weights';

export interface Factor {
  id: FactorId;
  /** Raw 0..1 strength before weighting. */
  value: number;
  /** Weighted contribution to the total score. */
  contribution: number;
  /** Human-readable clause for "why you're seeing this" (FR-FEED-3). */
  reason: string;
}

export interface ScoredEvent {
  event: LotivityEvent;
  score: number;
  factors: Factor[];
  /** Top two positive contributors, strongest first (FR-REC-2). */
  topFactors: Factor[];
  distanceMi: number;
}

export interface ScoreContext {
  user: Pick<User, 'id' | 'interests' | 'heritage' | 'cultureTags' | 'generation' | 'location'>;
  now: Date;
  radiusMi?: number;
  /** Peer ids used for the network-attendance term. */
  networkIds?: string[];
  /** Event ids already shown, used for the recency penalty. */
  seenEventIds?: string[];
  heritageLabel?: (id: string) => string;
  cultureLabel?: (id: string) => string;
  interestLabel?: (id: string) => string;
}

const overlap = (a: readonly string[], b: readonly string[]): number => {
  if (a.length === 0) return 0;
  const set = new Set(b);
  return a.filter((x) => set.has(x)).length / a.length;
};

/**
 * Scans in the *event's* tag order, not the user's. An event's first tag is its
 * primary subject, so a reading night explains itself as reading even when the
 * user also happens to follow a secondary tag on it.
 */
const firstShared = (userTags: readonly string[], eventTags: readonly string[]): string | undefined => {
  const owned = new Set(userTags);
  return eventTags.find((x) => owned.has(x));
};

const identity = (s: string) => s;

/**
 * Pure and deterministic: same (user, event, now) always yields the same score
 * and the same reasons (FR-REC-1).
 */
export function scoreEvent(event: LotivityEvent, ctx: ScoreContext): ScoredEvent {
  const radiusMi = ctx.radiusMi ?? DEFAULT_FEED_RADIUS_MI;
  const labelHeritage = ctx.heritageLabel ?? identity;
  const labelCulture = ctx.cultureLabel ?? identity;
  const labelInterest = ctx.interestLabel ?? identity;

  const factors: Factor[] = [];
  const add = (id: FactorId, value: number, reason: string) => {
    if (value === 0) return;
    factors.push({ id, value, contribution: value * WEIGHTS[id], reason });
  };

  const interestValue = overlap(ctx.user.interests, event.interestTags);
  const sharedInterest = firstShared(ctx.user.interests, event.interestTags);
  add(
    'interestOverlap',
    interestValue,
    sharedInterest ? `Because you follow ${labelInterest(sharedInterest)}` : 'Matches your interests',
  );

  const sharedHeritage = firstShared(ctx.user.heritage, event.heritageTags);
  add(
    'heritageMatch',
    sharedHeritage ? 1 : 0,
    sharedHeritage ? `${labelHeritage(sharedHeritage)} heritage` : '',
  );

  const sharedCulture = firstShared(ctx.user.cultureTags, event.cultureTags);
  add(
    'cultureMatch',
    sharedCulture ? 1 : 0,
    sharedCulture ? `For the ${labelCulture(sharedCulture)} community` : '',
  );

  add(
    'generationMatch',
    event.generationTags.includes(ctx.user.generation) ? 1 : 0,
    'Popular with your generation',
  );

  const distanceMi = distanceMiles(ctx.user.location, event.location);
  const proximity = proximityScore(ctx.user.location, event.location, radiusMi);
  add('proximity', proximity, `${distanceMi.toFixed(1)} mi away`);

  const network = ctx.networkIds ?? [];
  const attending = network.filter((id) => event.attendeeIds.includes(id)).length;
  const networkValue = network.length > 0 ? attending / network.length : 0;
  add(
    'networkAttendance',
    networkValue,
    attending === 1 ? '1 person you know is going' : `${attending} people you know are going`,
  );

  const seen = ctx.seenEventIds ?? [];
  const seenPenalty = seen.includes(event.id) ? 1 : 0;
  if (seenPenalty > 0) {
    factors.push({
      id: 'recencyPenalty',
      value: seenPenalty,
      contribution: -seenPenalty * WEIGHTS.recencyPenalty,
      reason: 'Already shown recently',
    });
  }

  const score = factors.reduce((sum, f) => sum + f.contribution, 0);
  const topFactors = factors
    .filter((f) => f.contribution > 0 && f.reason)
    .sort((a, b) => b.contribution - a.contribution)
    .slice(0, 2);

  return { event, score, factors, topFactors, distanceMi };
}

export function rankEvents(events: LotivityEvent[], ctx: ScoreContext): ScoredEvent[] {
  return events
    .map((event) => scoreEvent(event, ctx))
    .sort((a, b) => b.score - a.score || a.event.id.localeCompare(b.event.id));
}

export { WEIGHTS, DEFAULT_FEED_RADIUS_MI } from './weights';
