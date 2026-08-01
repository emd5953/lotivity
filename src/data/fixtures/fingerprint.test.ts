import { writeFileSync } from 'node:fs';
import { describe, expect, it } from 'vitest';
import { generateWorld } from './generate';

/**
 * Canonical, order-sensitive dump of the fixture world. The Swift port in
 * `ios/LotivityKit` emits the same string from the same seed — this file is how
 * that equivalence is checked rather than asserted.
 */
export function fingerprint(seed: number): string {
  const w = generateWorld(seed);
  const g = (p: { lat: number; lng: number }) => `${p.lat.toFixed(9)},${p.lng.toFixed(9)}`;
  const t = (iso: string) => iso.replace('.000Z', 'Z');
  const lines: string[] = [];

  for (const u of w.users) {
    lines.push(
      [
        u.id, u.name, u.dob, u.generation, u.accountType,
        u.heritage.join('+'), u.languages.join('+'), u.cultureTags.join('+'),
        u.interests.join('+'), u.interestSubcategories.join('+'),
        g(u.location), u.isGuest, u.youthVerification?.status ?? '-',
      ].join('|'),
    );
  }
  for (const b of w.businesses) {
    lines.push(
      [b.id, b.name, b.category, b.mapFilter, b.neighborhood, b.valueTags.join('+'),
        b.inNetwork, b.positiveVotes7d, g(b.location)].join('|'),
    );
  }
  for (const e of w.events) {
    lines.push(
      [e.id, e.title, e.hostId, e.hostType, e.category, e.neighborhood, e.venueId ?? '-',
        t(e.startsAt), t(e.endsAt), e.interestTags.join('+'), e.heritageTags.join('+'),
        e.cultureTags.join('+'), e.generationTags.join('+'), e.attendeeIds.join('+'),
        e.interestedIds.join('+'), e.requiresGuardian, e.sponsoredBy ?? '-',
        e.priceLabel ?? '-', g(e.location)].join('|'),
    );
  }
  for (const gr of w.groups) {
    lines.push(
      [gr.id, gr.name, gr.category, gr.description, gr.memberIds.join('+'), gr.radiusMi,
        g(gr.center), gr.neighborhood, gr.interestTags.join('+'), gr.cultureTags.join('+'),
        gr.sponsorship.state, gr.sponsorship.businessId ?? '-',
        gr.sponsorship.promoCode ?? '-'].join('|'),
    );
  }
  for (const r of w.requests) {
    lines.push(
      [r.id, r.authorId, r.description, r.radiusMi, g(r.center), r.targetInterests.join('+'),
        r.targetCulture.join('+'), r.targetGenerations.join('+'), r.notifiedCount, r.upvotes,
        r.upvoteThreshold, r.resolvedGroupId ?? '-'].join('|'),
    );
  }
  for (const p of w.posts) {
    lines.push(
      [p.id, p.authorId, p.eventId ?? '-', p.businessId ?? '-', p.body,
        p.voiceMemo ? `${p.voiceMemo.blobKey}:${p.voiceMemo.durationSec}:${p.voiceMemo.sentiment}` : '-',
        t(p.createdAt), t(p.visibleUntil)].join('|'),
    );
  }
  for (const c of w.connections) {
    lines.push([c.userId, c.peerId, c.origin, c.sharedEventId ?? '-', t(c.connectedAt)].join('|'));
  }

  return lines.join('\n');
}

describe('fixture fingerprint', () => {
  it('writes the canonical dump used to check the Swift port', () => {
    const out = process.env.FINGERPRINT_OUT;
    const text = `${fingerprint(20260728)}\n---\n${fingerprint(42)}`;
    if (out) writeFileSync(out, text);
    expect(text.length).toBeGreaterThan(1000);
  });
});
