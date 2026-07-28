import { ANCHOR, generateWorld, type World } from '@/data/fixtures/generate';

/**
 * Fixture timestamps are authored against a fixed anchor so the seed is
 * deterministic. At read time we slide the whole world onto the current date,
 * so "3 days from now" stays 3 days from now no matter when the demo runs.
 */
function rebase(world: World, now: Date): World {
  // Whole days only: a partial-day shift would drag every event off its
  // authored hour and produce 2 a.m. book clubs.
  const DAY_MS = 86_400_000;
  const delta = Math.round((now.getTime() - ANCHOR.getTime()) / DAY_MS) * DAY_MS;
  const shift = (isoDate: string) => new Date(new Date(isoDate).getTime() + delta).toISOString();

  return {
    ...world,
    events: world.events.map((e) => ({
      ...e,
      startsAt: shift(e.startsAt),
      endsAt: shift(e.endsAt),
    })),
    posts: world.posts.map((p) => ({
      ...p,
      createdAt: shift(p.createdAt),
      visibleUntil: shift(p.visibleUntil),
    })),
    connections: world.connections.map((c) => ({ ...c, connectedAt: shift(c.connectedAt) })),
  };
}

let cache: { world: World; builtFor: string } | null = null;

/**
 * The single source of fixture data. Everything else in repo/ reads from here;
 * features never import fixtures directly (BR-1).
 */
export function getWorld(now: Date = new Date()): World {
  // Rebasing daily is enough — nothing in the UI depends on sub-day drift.
  const key = now.toISOString().slice(0, 10);
  if (!cache || cache.builtFor !== key) {
    cache = { world: rebase(generateWorld(), now), builtFor: key };
  }
  return cache.world;
}

/** Test helper — forces the next getWorld() to rebuild. */
export function resetWorldCache(): void {
  cache = null;
}
