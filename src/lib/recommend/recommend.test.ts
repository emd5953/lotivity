import { describe, expect, it } from 'vitest';
import type { LotivityEvent } from '@/data/schema';
import { rankEvents, scoreEvent, WEIGHTS, type ScoreContext } from './index';

const CENTER = { lat: 40.7265, lng: -73.9815 };

const baseUser: ScoreContext['user'] = {
  id: 'user:me',
  interests: ['interest:running', 'interest:music'],
  heritage: ['heritage:colombia'],
  cultureTags: ['faith:christian', 'community:latin'],
  generation: 'millennial',
  location: CENTER,
};

const baseCtx = (over: Partial<ScoreContext> = {}): ScoreContext => ({
  user: baseUser,
  now: new Date('2026-07-28T12:00:00Z'),
  radiusMi: 5,
  ...over,
});

function makeEvent(over: Partial<LotivityEvent> = {}): LotivityEvent {
  return {
    id: 'event:1',
    title: 'Test event',
    hostId: 'user:1',
    hostType: 'user',
    category: 'social',
    // Far enough that proximity contributes ~0 unless a test moves it.
    location: { lat: 40.8618, lng: -73.8905 },
    neighborhood: 'Fordham',
    startsAt: '2026-07-30T18:00:00Z',
    endsAt: '2026-07-30T20:00:00Z',
    interestTags: [],
    heritageTags: [],
    cultureTags: [],
    generationTags: [],
    attendeeIds: [],
    interestedIds: [],
    requiresGuardian: false,
    ...over,
  };
}

describe('scoreEvent — factors in isolation', () => {
  it('scores nothing when nothing matches', () => {
    const { score } = scoreEvent(makeEvent(), baseCtx());
    expect(score).toBe(0);
  });

  it('weights partial interest overlap proportionally', () => {
    // One of the user's two interests matches → 0.5 × 3.0
    const { score } = scoreEvent(makeEvent({ interestTags: ['interest:running'] }), baseCtx());
    expect(score).toBeCloseTo(0.5 * WEIGHTS.interestOverlap, 5);
  });

  it('applies heritage match as a flat term', () => {
    const { score } = scoreEvent(makeEvent({ heritageTags: ['heritage:colombia'] }), baseCtx());
    expect(score).toBeCloseTo(WEIGHTS.heritageMatch, 5);
  });

  it('applies culture match as a flat term', () => {
    const { score } = scoreEvent(makeEvent({ cultureTags: ['faith:christian'] }), baseCtx());
    expect(score).toBeCloseTo(WEIGHTS.cultureMatch, 5);
  });

  it('applies generation match as a flat term', () => {
    const { score } = scoreEvent(makeEvent({ generationTags: ['millennial'] }), baseCtx());
    expect(score).toBeCloseTo(WEIGHTS.generationMatch, 5);
  });

  it('gives full proximity credit at the user location', () => {
    const { score } = scoreEvent(makeEvent({ location: CENTER }), baseCtx());
    expect(score).toBeCloseTo(WEIGHTS.proximity, 5);
  });

  it('scales network attendance by the share of the network going', () => {
    const { score } = scoreEvent(
      makeEvent({ attendeeIds: ['user:a', 'user:b'] }),
      baseCtx({ networkIds: ['user:a', 'user:b', 'user:c', 'user:d'] }),
    );
    expect(score).toBeCloseTo(0.5 * WEIGHTS.networkAttendance, 5);
  });

  it('subtracts the recency penalty for an event already shown', () => {
    const { score } = scoreEvent(
      makeEvent({ generationTags: ['millennial'] }),
      baseCtx({ seenEventIds: ['event:1'] }),
    );
    expect(score).toBeCloseTo(WEIGHTS.generationMatch - WEIGHTS.recencyPenalty, 5);
  });
});

describe('scoreEvent — reasons', () => {
  it('returns the two strongest positive factors, strongest first', () => {
    const { topFactors } = scoreEvent(
      makeEvent({
        location: CENTER,
        interestTags: ['interest:running', 'interest:music'],
        generationTags: ['millennial'],
      }),
      baseCtx(),
    );

    // interest (1.0 × 3.0) then proximity (1.0 × 2.0), ahead of generation (1.0).
    expect(topFactors).toHaveLength(2);
    expect(topFactors[0]?.id).toBe('interestOverlap');
    expect(topFactors[1]?.id).toBe('proximity');
  });

  it('names the matched interest in the reason', () => {
    const { topFactors } = scoreEvent(
      makeEvent({ interestTags: ['interest:running'] }),
      baseCtx({ interestLabel: () => 'Running' }),
    );
    expect(topFactors[0]?.reason).toBe('Because you follow Running');
  });

  it("names the event's primary subject, not the user's first-listed interest", () => {
    // User lists Running before Music, but this is a music event that happens
    // to also carry a running tag. Explaining it as Running reads as a bug.
    const { topFactors } = scoreEvent(
      makeEvent({ interestTags: ['interest:music', 'interest:running'] }),
      baseCtx({ interestLabel: (id) => (id === 'interest:music' ? 'Music' : 'Running') }),
    );
    expect(topFactors[0]?.reason).toBe('Because you follow Music');
  });

  it('never surfaces the recency penalty as a reason', () => {
    const { topFactors } = scoreEvent(
      makeEvent({ generationTags: ['millennial'] }),
      baseCtx({ seenEventIds: ['event:1'] }),
    );
    expect(topFactors.every((f) => f.id !== 'recencyPenalty')).toBe(true);
  });
});

describe('rankEvents', () => {
  const strong = makeEvent({
    id: 'event:strong',
    location: CENTER,
    interestTags: ['interest:running', 'interest:music'],
    heritageTags: ['heritage:colombia'],
  });
  const weak = makeEvent({ id: 'event:weak' });

  it('orders by descending score', () => {
    const ranked = rankEvents([weak, strong], baseCtx());
    expect(ranked.map((r) => r.event.id)).toEqual(['event:strong', 'event:weak']);
  });

  it('is deterministic — same inputs, same order (FR-REC-1)', () => {
    const a = rankEvents([weak, strong], baseCtx()).map((r) => r.event.id);
    const b = rankEvents([weak, strong], baseCtx()).map((r) => r.event.id);
    expect(a).toEqual(b);
  });

  it('breaks ties stably by id rather than input order', () => {
    const tieA = makeEvent({ id: 'event:aaa' });
    const tieB = makeEvent({ id: 'event:bbb' });
    expect(rankEvents([tieB, tieA], baseCtx()).map((r) => r.event.id)).toEqual([
      'event:aaa',
      'event:bbb',
    ]);
  });
});
