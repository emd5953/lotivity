import { Link } from 'react-router-dom';
import type { Business } from '@/data/schema';
import { Card, Pill } from '@/ui';

/**
 * FR-FEED-4 — the heritage notification voice from the concept notes, e.g.
 * "This Friday, check out Colombian restaurant ___ for happy hour."
 */
export function HeritageNotice({
  heritageLabel,
  business,
  weekday,
  positiveVotes,
}: {
  heritageLabel: string;
  business: Business;
  weekday: string;
  positiveVotes: number;
}) {
  return (
    <Card as="li" className="border-brand/30 bg-brand-soft/50 space-y-3">
      <Pill tone="brand">{heritageLabel} heritage</Pill>
      <p className="text-[1.05rem] leading-snug">
        This {weekday}, check out {heritageLabel} spot{' '}
        <span className="font-semibold">{business.name}</span> for happy hour in {business.neighborhood}.
      </p>
      <p className="text-sm text-muted">
        {positiveVotes} people with {heritageLabel} heritage voted it a positive experience this past
        week.
      </p>
      {/* FR-FEED-5 — deep-links into the recap; Social lands in M6. */}
      <Link
        to={`/social?recap=${business.id}`}
        className="inline-block text-sm font-medium text-brand underline underline-offset-4"
      >
        Check out the recap highlights →
      </Link>
    </Card>
  );
}
