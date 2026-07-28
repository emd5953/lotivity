import type {
  ActivityRequest,
  Business,
  Connection,
  GeoPoint,
  Group,
  ID,
  LotivityEvent,
  MapFilter,
  Post,
  PublicUser,
  User,
} from '@/data/schema';
import { distanceMiles, withinRadius } from '@/lib/geo';
import { getWorld } from './world';

/**
 * Async by design: these signatures are what a real API will return, so
 * swapping the fixture backing is a change confined to this directory (BR-1).
 */
const resolve = <T>(value: T): Promise<T> => Promise.resolve(value);

/**
 * Strips date of birth. This is the only place a User becomes shareable, which
 * is what keeps FR-PROF-2 true regardless of what components do (BR-5).
 */
export function toPublicUser(user: User): PublicUser {
  const { dob: _dob, ...rest } = user;
  return rest;
}

export async function getPublicUser(id: ID): Promise<PublicUser | null> {
  const user = getWorld().users.find((u) => u.id === id);
  return resolve(user ? toPublicUser(user) : null);
}

export async function getPublicUsers(ids: ID[]): Promise<PublicUser[]> {
  const wanted = new Set(ids);
  return resolve(getWorld().users.filter((u) => wanted.has(u.id)).map(toPublicUser));
}

export async function getEvent(id: ID): Promise<LotivityEvent | null> {
  return resolve(getWorld().events.find((e) => e.id === id) ?? null);
}

export async function getBusiness(id: ID): Promise<Business | null> {
  return resolve(getWorld().businesses.find((b) => b.id === id) ?? null);
}

export async function getGroup(id: ID): Promise<Group | null> {
  return resolve(getWorld().groups.find((g) => g.id === id) ?? null);
}

/** Future events only, nearest first — the candidate pool for ranking. */
export async function getUpcomingEvents(now: Date = new Date()): Promise<LotivityEvent[]> {
  const events = getWorld(now)
    .events.filter((e) => new Date(e.startsAt).getTime() >= now.getTime())
    .sort((a, b) => a.startsAt.localeCompare(b.startsAt));
  return resolve(events);
}

export async function getPastEvents(now: Date = new Date()): Promise<LotivityEvent[]> {
  const events = getWorld(now)
    .events.filter((e) => new Date(e.endsAt).getTime() < now.getTime())
    .sort((a, b) => b.startsAt.localeCompare(a.startsAt));
  return resolve(events);
}

export async function getGroups(): Promise<Group[]> {
  return resolve(getWorld().groups);
}

export async function getActivityRequests(): Promise<ActivityRequest[]> {
  return resolve(getWorld().requests);
}

export async function getBusinesses(): Promise<Business[]> {
  return resolve(getWorld().businesses);
}

/**
 * Event posts are visible for 7 days, and only to people who attended or were
 * interested (FR-SOCIAL-2). Enforced here so the rule survives a real backend.
 */
export async function getVisiblePosts(
  viewerId: ID,
  now: Date = new Date(),
): Promise<Post[]> {
  const world = getWorld(now);
  const eventsById = new Map(world.events.map((e) => [e.id, e]));

  const posts = world.posts.filter((post) => {
    if (new Date(post.visibleUntil).getTime() < now.getTime()) return false;
    if (!post.eventId) return true;

    const event = eventsById.get(post.eventId);
    if (!event) return false;
    return (
      post.authorId === viewerId ||
      event.attendeeIds.includes(viewerId) ||
      event.interestedIds.includes(viewerId)
    );
  });

  return resolve(posts.sort((a, b) => b.createdAt.localeCompare(a.createdAt)));
}

export async function getConnections(userId: ID): Promise<Connection[]> {
  return resolve(getWorld().connections.filter((c) => c.userId === userId));
}

export interface MapItem {
  id: ID;
  kind: 'event' | 'group' | 'business';
  filter: MapFilter;
  title: string;
  subtitle: string;
  location: GeoPoint;
  distanceMi: number;
}

/** Everything pinnable within the radius, already filtered and measured. */
export async function getMapItems(options: {
  center: GeoPoint;
  radiusMi: number;
  filters: MapFilter[];
  now?: Date;
}): Promise<MapItem[]> {
  const { center, radiusMi, filters } = options;
  const now = options.now ?? new Date();
  const world = getWorld(now);
  const active = new Set(filters);
  const items: MapItem[] = [];

  if (active.has('events')) {
    for (const event of world.events) {
      if (new Date(event.startsAt).getTime() < now.getTime()) continue;
      if (!withinRadius(center, event.location, radiusMi)) continue;
      items.push({
        id: event.id,
        kind: 'event',
        filter: 'events',
        title: event.title,
        subtitle: event.neighborhood,
        location: event.location,
        distanceMi: distanceMiles(center, event.location),
      });
    }
  }

  if (active.has('clubs')) {
    for (const group of world.groups) {
      if (!withinRadius(center, group.center, radiusMi)) continue;
      items.push({
        id: group.id,
        kind: 'group',
        filter: 'clubs',
        title: group.name,
        subtitle: `${group.memberIds.length} members · ${group.neighborhood}`,
        location: group.center,
        distanceMi: distanceMiles(center, group.center),
      });
    }
  }

  for (const business of world.businesses) {
    if (!active.has(business.mapFilter)) continue;
    if (!withinRadius(center, business.location, radiusMi)) continue;
    items.push({
      id: business.id,
      kind: 'business',
      filter: business.mapFilter,
      title: business.name,
      subtitle: `${business.category} · ${business.neighborhood}`,
      location: business.location,
      distanceMi: distanceMiles(center, business.location),
    });
  }

  return resolve(items.sort((a, b) => a.distanceMi - b.distanceMi));
}

/** Places the viewer's network has been in the last 7 days (FR-MAP-5). */
export async function getNetworkTrail(
  userId: ID,
  now: Date = new Date(),
): Promise<MapItem[]> {
  const world = getWorld(now);
  const peers = new Set(world.connections.filter((c) => c.userId === userId).map((c) => c.peerId));
  const cutoff = now.getTime() - 7 * 86_400_000;

  const trail = world.events
    .filter((e) => {
      const ended = new Date(e.endsAt).getTime();
      if (ended > now.getTime() || ended < cutoff) return false;
      return e.attendeeIds.some((id) => peers.has(id));
    })
    .map((e) => ({
      id: e.id,
      kind: 'event' as const,
      filter: 'events' as const,
      title: e.title,
      subtitle: `${e.attendeeIds.filter((id) => peers.has(id)).length} in your network went`,
      location: e.location,
      distanceMi: 0,
    }));

  return resolve(trail);
}

export { getWorld, resetWorldCache } from './world';
