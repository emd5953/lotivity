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
          <p className="text-xs font-medium uppercase tracking-wide text-muted">
            {dayFormatter.format(starts)} · {timeFormatter.format(starts)}
          </p>
          <h3 className="mt-1 text-[1.05rem] font-semibold leading-snug">{event.title}</h3>
          <p className="mt-1 text-sm text-muted">
            {event.neighborhood} · {distanceMi.toFixed(1)} mi
          </p>
        </div>
        {event.sponsoredBy ? <Pill tone="accent">Sponsored</Pill> : null}
      </div>

      <div className="flex flex-wrap gap-1.5">
        {event.priceLabel ? <Pill>{event.priceLabel}</Pill> : <Pill tone="brand">Free</Pill>}
        <Pill>{event.attendeeIds.length} going</Pill>
        {event.requiresGuardian ? <Pill tone="warn">Guardian required</Pill> : null}
      </div>

      {/* FR-FEED-3 — the card explains itself. */}
      {topFactors.length > 0 ? (
        <p className="border-t border-line pt-3 text-sm text-muted">
          {topFactors.map((f) => f.reason).join(' · ')}
        </p>
      ) : null}
    </Card>
  );
}
