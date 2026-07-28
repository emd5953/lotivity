import { describe, expect, it } from 'vitest';
import { distanceMiles, filterByRadius, proximityScore, withinRadius } from './index';

const EAST_VILLAGE = { lat: 40.7265, lng: -73.9815 };
const WILLIAMSBURG = { lat: 40.7143, lng: -73.9613 };
const FORDHAM = { lat: 40.8618, lng: -73.8905 };

describe('distanceMiles', () => {
  it('is zero for the same point', () => {
    expect(distanceMiles(EAST_VILLAGE, EAST_VILLAGE)).toBe(0);
  });

  it('measures a known short hop across the East River', () => {
    // East Village → Williamsburg is a little over 1.35 mi as the crow flies.
    expect(distanceMiles(EAST_VILLAGE, WILLIAMSBURG)).toBeCloseTo(1.35, 2);
  });

  it('is symmetric', () => {
    expect(distanceMiles(EAST_VILLAGE, FORDHAM)).toBeCloseTo(
      distanceMiles(FORDHAM, EAST_VILLAGE),
      6,
    );
  });
});

describe('withinRadius', () => {
  it('includes points on the boundary and excludes points past it', () => {
    const d = distanceMiles(EAST_VILLAGE, WILLIAMSBURG);
    expect(withinRadius(EAST_VILLAGE, WILLIAMSBURG, d)).toBe(true);
    expect(withinRadius(EAST_VILLAGE, WILLIAMSBURG, d - 0.01)).toBe(false);
  });
});

describe('proximityScore', () => {
  it('is 1 at the center and 0 at the edge', () => {
    expect(proximityScore(EAST_VILLAGE, EAST_VILLAGE, 5)).toBe(1);
    const d = distanceMiles(EAST_VILLAGE, WILLIAMSBURG);
    expect(proximityScore(EAST_VILLAGE, WILLIAMSBURG, d)).toBeCloseTo(0, 5);
  });

  it('clamps to 0 beyond the radius rather than going negative', () => {
    expect(proximityScore(EAST_VILLAGE, FORDHAM, 1)).toBe(0);
  });

  it('is 0 for a zero radius instead of dividing by zero', () => {
    expect(proximityScore(EAST_VILLAGE, WILLIAMSBURG, 0)).toBe(0);
  });
});

describe('filterByRadius', () => {
  it('keeps only items inside the radius', () => {
    const items = [
      { id: 'near', at: WILLIAMSBURG },
      { id: 'far', at: FORDHAM },
    ];
    const kept = filterByRadius(items, EAST_VILLAGE, 3, (i) => i.at);
    expect(kept.map((i) => i.id)).toEqual(['near']);
  });
});
