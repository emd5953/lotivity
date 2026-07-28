import { beforeEach, describe, expect, it } from 'vitest';
import { generateWorld } from '@/data/fixtures/generate';
import {
  getMapItems,
  getPublicUser,
  getVisiblePosts,
  getWorld,
  resetWorldCache,
  toPublicUser,
} from './index';
import { DEFAULT_CENTER } from '@/data/reference/nyc';
import { distanceMiles } from '@/lib/geo';

beforeEach(() => resetWorldCache());

describe('privacy (BR-5)', () => {
  it('never exposes dob on a public user', async () => {
    const user = await getPublicUser('user:1');
    expect(user).not.toBeNull();
    expect(user).not.toHaveProperty('dob');
  });

  it('keeps generation, which is the signal that is meant to be visible', async () => {
    const user = await getPublicUser('user:1');
    expect(user?.generation).toBeTruthy();
  });

  it('strips dob from every user in the world, not just the ones we query', () => {
    for (const user of getWorld().users) {
      expect(toPublicUser(user)).not.toHaveProperty('dob');
    }
  });
});

describe('fixture generation', () => {
  it('is deterministic for a given seed', () => {
    expect(JSON.stringify(generateWorld(42))).toBe(JSON.stringify(generateWorld(42)));
  });

  it('differs across seeds, so the determinism above is meaningful', () => {
    expect(JSON.stringify(generateWorld(1))).not.toBe(JSON.stringify(generateWorld(2)));
  });

  it('meets the volumes the TRD calls for', () => {
    const world = getWorld();
    expect(world.users.length).toBeGreaterThanOrEqual(60);
    expect(world.events.length).toBeGreaterThanOrEqual(40);
    expect(world.businesses.length).toBeGreaterThanOrEqual(25);
    expect(world.groups.length).toBeGreaterThanOrEqual(12);
    expect(world.requests.length).toBeGreaterThanOrEqual(8);
    expect(world.posts.length).toBeGreaterThanOrEqual(80);
  });

  it('has roughly 15 in-network businesses, per the PRD launch target', () => {
    expect(getWorld().businesses.filter((b) => b.inNetwork)).toHaveLength(15);
  });

  it('schedules every event at an hour people actually gather', () => {
    // Guards the whole-day rebase: a partial-day shift produced 2 a.m. book clubs.
    for (const event of getWorld().events) {
      const etHour = new Date(
        new Date(event.startsAt).getTime() - 4 * 3_600_000,
      ).getUTCHours();
      expect(etHour).toBeGreaterThanOrEqual(7);
      expect(etHour).toBeLessThanOrEqual(20);
    }
  });

  it('does not schedule a "night" event in the morning', () => {
    for (const event of getWorld().events) {
      if (!/night|evening|open mic/i.test(event.title)) continue;
      const etHour = new Date(new Date(event.startsAt).getTime() - 4 * 3_600_000).getUTCHours();
      expect(etHour).toBeGreaterThanOrEqual(17);
    }
  });

  it('does not name a weekday in a title, since the day is picked separately', () => {
    const weekday = /monday|tuesday|wednesday|thursday|friday|saturday|sunday/i;
    for (const event of getWorld().events) {
      expect(event.title).not.toMatch(weekday);
    }
  });

  it('starts events on the hour or half hour', () => {
    for (const event of getWorld().events) {
      expect([0, 30]).toContain(new Date(event.startsAt).getUTCMinutes());
    }
  });

  it('seeds both past and future events so recaps have material', () => {
    const now = Date.now();
    const world = getWorld();
    expect(world.events.some((e) => new Date(e.startsAt).getTime() < now)).toBe(true);
    expect(world.events.some((e) => new Date(e.startsAt).getTime() > now)).toBe(true);
  });
});

describe('getMapItems', () => {
  it('returns only items inside the radius', async () => {
    const items = await getMapItems({
      center: DEFAULT_CENTER,
      radiusMi: 1,
      filters: ['events', 'clubs', 'workshops', 'food'],
    });
    for (const item of items) {
      expect(distanceMiles(DEFAULT_CENTER, item.location)).toBeLessThanOrEqual(1);
    }
  });

  it('returns strictly more as the radius grows', async () => {
    const filters = ['events', 'clubs', 'workshops', 'food'] as const;
    const near = await getMapItems({ center: DEFAULT_CENTER, radiusMi: 1, filters: [...filters] });
    const far = await getMapItems({ center: DEFAULT_CENTER, radiusMi: 10, filters: [...filters] });
    expect(far.length).toBeGreaterThan(near.length);
  });

  it('honors filters', async () => {
    const items = await getMapItems({
      center: DEFAULT_CENTER,
      radiusMi: 10,
      filters: ['food'],
    });
    expect(items.length).toBeGreaterThan(0);
    expect(items.every((i) => i.filter === 'food')).toBe(true);
  });

  it('sorts nearest first', async () => {
    const items = await getMapItems({
      center: DEFAULT_CENTER,
      radiusMi: 5,
      filters: ['events'],
    });
    const distances = items.map((i) => i.distanceMi);
    expect([...distances].sort((a, b) => a - b)).toEqual(distances);
  });
});

describe('post visibility (FR-SOCIAL-2)', () => {
  it('hides event posts from people who neither attended nor were interested', async () => {
    const world = getWorld();
    const eventPost = world.posts.find((p) => p.eventId);
    expect(eventPost).toBeDefined();

    const event = world.events.find((e) => e.id === eventPost?.eventId);
    expect(event).toBeDefined();

    const outsider = world.users.find(
      (u) =>
        !event?.attendeeIds.includes(u.id) &&
        !event?.interestedIds.includes(u.id) &&
        u.id !== eventPost?.authorId,
    );
    expect(outsider).toBeDefined();

    const visible = await getVisiblePosts(outsider!.id);
    expect(visible.some((p) => p.id === eventPost!.id)).toBe(false);
  });

  it('shows an event post to someone who attended', async () => {
    const now = new Date();
    const world = getWorld(now);
    // Must still be inside its 7-day window, or expiry masks the attendee rule.
    const eventPost = world.posts.find((p) => {
      if (!p.eventId) return false;
      if (new Date(p.visibleUntil).getTime() < now.getTime()) return false;
      const event = world.events.find((e) => e.id === p.eventId);
      return (event?.attendeeIds.length ?? 0) > 0;
    });
    expect(eventPost).toBeDefined();

    const event = world.events.find((e) => e.id === eventPost!.eventId)!;
    const attendee = event.attendeeIds[0]!;

    const visible = await getVisiblePosts(attendee, now);
    expect(visible.some((p) => p.id === eventPost!.id)).toBe(true);
  });

  it('never returns a post past its 7-day window', async () => {
    const now = new Date();
    const visible = await getVisiblePosts('user:1', now);
    for (const post of visible) {
      expect(new Date(post.visibleUntil).getTime()).toBeGreaterThanOrEqual(now.getTime());
    }
  });
});
