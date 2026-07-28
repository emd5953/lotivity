import { useEffect, useMemo, useState } from 'react';
import { Link } from 'react-router-dom';
import { guestProfile, useAppStore } from '@/app/store';
import { getBusinesses, getUpcomingEvents, getWorld } from '@/data/repo';
import type { Business } from '@/data/schema';
import { HERITAGE_BY_ID, heritageLabel } from '@/data/reference/heritage';
import { cultureLabel } from '@/data/reference/culture';
import { interestLabel } from '@/data/reference/interests';
import { rankEvents, type ScoredEvent } from '@/lib/recommend';
import { Card, EmptyState, Pill, ScreenHeader } from '@/ui';
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
  const savedProfile = useAppStore((s) => s.profile);
  const location = useAppStore((s) => s.location);
  const isGuest = savedProfile === null;
  // Guests see the real feed, ranked by what's actually close (PRD §9.3).
  const profile = useMemo(
    () => savedProfile ?? guestProfile(location),
    [savedProfile, location],
  );

  const [ranked, setRanked] = useState<ScoredEvent[] | null>(null);
  const [heritagePick, setHeritagePick] = useState<HeritagePick | null>(null);

  useEffect(() => {
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
        networkIds: isGuest ? [] : networkIds,
        // A guest has no network and no declared generation — scoring on
        // either would put a claim on the card that isn't true.
        suppressFactors: isGuest ? ['generationMatch', 'networkAttendance'] : [],
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
  }, [profile, isGuest]);

  return (
    <>
      <ScreenHeader
        title={isGuest ? 'Around you' : `Hey, ${profile.name.split(' ')[0]}`}
        subtitle={
          isGuest
            ? "What's happening near you this week."
            : "What's worth leaving the house for this week."
        }
        trailing={
          isGuest ? null : <Pill tone="accent">{generationLabel(profile.generation)}</Pill>
        }
      />

      {isGuest ? (
        <Card className="mb-4 space-y-2">
          <p className="font-display font-semibold tracking-card text-cream">
            You&rsquo;re browsing as a guest
          </p>
          <p className="text-sm leading-relaxed text-cream/45">
            This is sorted by what&rsquo;s closest. Tell us what you&rsquo;re into and it gets
            sorted by what&rsquo;s actually for you.
          </p>
          <Link
            to="/welcome"
            className="inline-block text-sm font-medium text-accent underline underline-offset-4 hover:text-accent-hi"
          >
            Set up your profile →
          </Link>
        </Card>
      ) : null}

      {ranked === null ? (
        <p className="eyebrow py-10 text-center">Finding things near you…</p>
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
        <Link
          to="/work"
          className="text-sm font-medium text-accent underline underline-offset-4 hover:text-accent-hi"
        >
          Looking for something with your team? →
        </Link>
      </div>
    </>
  );
}
