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
    <Card as="li" className="space-y-3 ring-accent/25">
      <Pill tone="accent">{heritageLabel} heritage</Pill>
      <p className="text-[1.0625rem] leading-snug text-cream">
        This {weekday}, check out {heritageLabel} spot{' '}
        <span className="font-display font-semibold tracking-card">{business.name}</span> for happy
        hour in {business.neighborhood}.
      </p>
      <p className="text-sm text-cream/45">
        <span className="font-mono tabular-nums">{positiveVotes}</span> people with {heritageLabel}{' '}
        heritage voted it a positive experience this past week.
      </p>
      {/* FR-FEED-5 — deep-links into the recap; Social lands in M6. */}
      <Link
        to={`/social?recap=${business.id}`}
        className="inline-block text-sm font-medium text-accent underline underline-offset-4 hover:text-accent-hi"
      >
        Check out the recap highlights →
      </Link>
    </Card>
  );
}
