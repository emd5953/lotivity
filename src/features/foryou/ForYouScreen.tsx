import { useEffect, useState } from 'react';
import { Link } from 'react-router-dom';
import { useAppStore } from '@/app/store';
import { getBusinesses, getUpcomingEvents, getWorld } from '@/data/repo';
import type { Business } from '@/data/schema';
import { HERITAGE_BY_ID, heritageLabel } from '@/data/reference/heritage';
import { cultureLabel } from '@/data/reference/culture';
import { interestLabel } from '@/data/reference/interests';
import { rankEvents, type ScoredEvent } from '@/lib/recommend';
import { EmptyState, Pill, ScreenHeader } from '@/ui';
import { generationLabel } from '@/lib/generation';
import { EventCard } from './EventCard';
import { HeritageNotice } from './HeritageNotice';

const weekdayFormatter = new Intl.DateTimeFormat('en-US', { weekday: 'long' });

/** Pre-filled during onboarding, so it rarely reflects a deliberate choice. */
const HOME_HERITAGE = 'heritage:united-states';

interface HeritagePick {
  heritageLabel: string;
  business: Business;
  weekday: string;
  positiveVotes: number;
}

export function ForYouScreen() {
  const profile = useAppStore((s) => s.profile);
  const [ranked, setRanked] = useState<ScoredEvent[] | null>(null);
  const [heritagePick, setHeritagePick] = useState<HeritagePick | null>(null);

  useEffect(() => {
    if (!profile) return;
    let cancelled = false;

    void (async () => {
      const now = new Date();
      const [events, businesses] = await Promise.all([getUpcomingEvents(now), getBusinesses()]);

      // Network is fixture-side: the demo profile has no connections yet, so
      // borrow the seeded graph to keep the term meaningful.
      const world = getWorld(now);
      const networkIds = world.connections
        .filter((c) => c.userId === 'user:1')
        .map((c) => c.peerId);

      const scored = rankEvents(events, {
        user: profile,
        now,
        networkIds,
        heritageLabel,
        cultureLabel,
        interestLabel,
      });

      // Prefer a heritage the user actually chose over the auto-filled home
      // country — "American spot" is a weaker hook than "Colombian spot".
      const heritageId =
        profile.heritage.find((id) => id !== HOME_HERITAGE) ?? profile.heritage[0];
      const heritage = heritageId ? HERITAGE_BY_ID.get(heritageId) : undefined;
      const inNetwork = businesses.filter((b) => b.inNetwork && b.mapFilter === 'food');
      const pick = inNetwork[0];

      if (!cancelled) {
        setRanked(scored);
        setHeritagePick(
          heritage && pick
            ? {
                heritageLabel: heritage.label,
                business: pick,
                weekday: weekdayFormatter.format(
                  new Date(now.getTime() + 2 * 86_400_000),
                ),
                positiveVotes: pick.positiveVotes7d,
              }
            : null,
        );
      }
    })();

    return () => {
      cancelled = true;
    };
  }, [profile]);

  if (!profile) return null;

  return (
    <>
      <ScreenHeader
        title={`Hey, ${profile.name.split(' ')[0]}`}
        subtitle="What's worth leaving the house for this week."
        trailing={<Pill tone="brand">{generationLabel(profile.generation)}</Pill>}
      />

      {ranked === null ? (
        <p className="py-10 text-center text-muted">Finding things near you…</p>
      ) : ranked.length === 0 ? (
        <EmptyState
          title="Nothing nearby yet"
          body="Widen your radius on the map to see what's happening further out."
        />
      ) : (
        <ul className="space-y-3">
          {ranked.slice(0, 4).map((scored) => (
            <EventCard key={scored.event.id} scored={scored} />
          ))}

          {heritagePick ? <HeritageNotice {...heritagePick} /> : null}

          {ranked.slice(4, 18).map((scored) => (
            <EventCard key={scored.event.id} scored={scored} />
          ))}
        </ul>
      )}

      <div className="pt-6 text-center">
        <Link to="/work" className="text-sm font-medium text-brand underline underline-offset-4">
          Looking for something with your team? →
        </Link>
      </div>
    </>
  );
}
