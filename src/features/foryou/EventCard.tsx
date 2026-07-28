import type { ScoredEvent } from '@/lib/recommend';
import { Card, Pill } from '@/ui';

const dayFormatter = new Intl.DateTimeFormat('en-US', {
  weekday: 'short',
  month: 'short',
  day: 'numeric',
});
const timeFormatter = new Intl.DateTimeFormat('en-US', { hour: 'numeric', minute: '2-digit' });

export function EventCard({ scored }: { scored: ScoredEvent }) {
  const { event, topFactors, distanceMi } = scored;
  const starts = new Date(event.startsAt);

  return (
    <Card as="li" className="space-y-3">
      <div className="flex items-start justify-between gap-3">
        <div>
          <p className="eyebrow">
            {dayFormatter.format(starts)} · {timeFormatter.format(starts)}
          </p>
          <h3 className="mt-1.5 text-[1.0625rem] font-semibold leading-snug tracking-card text-cream">
            {event.title}
          </h3>
          <p className="mt-1 text-sm text-cream/45">
            {event.neighborhood} ·{' '}
            <span className="font-mono tabular-nums">{distanceMi.toFixed(1)} mi</span>
          </p>
        </div>
        {/* A sponsor is informational — it is not the user's own aliveness. */}
        {event.sponsoredBy ? <Pill tone="info">Sponsored</Pill> : null}
      </div>

      <div className="flex flex-wrap gap-1.5">
        {event.priceLabel ? <Pill>{event.priceLabel}</Pill> : <Pill tone="accent">Free</Pill>}
        <Pill>{event.attendeeIds.length} going</Pill>
        {event.requiresGuardian ? <Pill tone="warn">Guardian required</Pill> : null}
      </div>

      {/* FR-FEED-3 — the card explains itself. Separated by a luminance step
          rather than a rule (DESIGN_SPEC §1.4). */}
      {topFactors.length > 0 ? (
        <p className="-mx-4 -mb-4 rounded-b-card bg-cream/2.2 px-4 py-3 text-sm text-cream/45">
          {topFactors.map((f) => f.reason).join(' · ')}
        </p>
      ) : null}
    </Card>
  );
}
