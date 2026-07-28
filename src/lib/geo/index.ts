import type { GeoPoint } from '@/data/schema';

const EARTH_RADIUS_MI = 3958.8;
const toRad = (deg: number) => (deg * Math.PI) / 180;

/**
 * Great-circle distance in miles. Kept pure so the same semantics can move to
 * PostGIS without behavior change (BR-4).
 */
export function distanceMiles(a: GeoPoint, b: GeoPoint): number {
  const dLat = toRad(b.lat - a.lat);
  const dLng = toRad(b.lng - a.lng);
  const lat1 = toRad(a.lat);
  const lat2 = toRad(b.lat);

  const h =
    Math.sin(dLat / 2) ** 2 + Math.sin(dLng / 2) ** 2 * Math.cos(lat1) * Math.cos(lat2);
  return 2 * EARTH_RADIUS_MI * Math.asin(Math.min(1, Math.sqrt(h)));
}

export const withinRadius = (center: GeoPoint, point: GeoPoint, radiusMi: number): boolean =>
  distanceMiles(center, point) <= radiusMi;

export function filterByRadius<T>(
  items: T[],
  center: GeoPoint,
  radiusMi: number,
  locate: (item: T) => GeoPoint,
): T[] {
  return items.filter((item) => withinRadius(center, locate(item), radiusMi));
}

/**
 * 1 at the center, 0 at the radius edge, clamped. Used by the recommendation
 * engine's proximity term (TRD §6).
 */
export function proximityScore(center: GeoPoint, point: GeoPoint, radiusMi: number): number {
  if (radiusMi <= 0) return 0;
  const d = distanceMiles(center, point);
  return Math.max(0, Math.min(1, 1 - d / radiusMi));
}

export function formatDistance(miles: number): string {
  if (miles < 0.1) return 'right here';
  if (miles < 0.5) return `${Math.round(miles * 5280 / 100) * 100} ft away`;
  return `${miles.toFixed(1)} mi away`;
}

/** Square bounds around a center, sized to hold the radius. */
export function boundsForRadius(center: GeoPoint, radiusMi: number): [GeoPoint, GeoPoint] {
  const latDelta = radiusMi / 69;
  const lngDelta = radiusMi / (69 * Math.max(0.1, Math.cos(toRad(center.lat))));
  return [
    { lat: center.lat - latDelta, lng: center.lng - lngDelta },
    { lat: center.lat + latDelta, lng: center.lng + lngDelta },
  ];
}

/** Deterministic offset used by fixtures to scatter points inside a neighborhood. */
export function offsetPoint(origin: GeoPoint, miNorth: number, miEast: number): GeoPoint {
  return {
    lat: origin.lat + miNorth / 69,
    lng: origin.lng + miEast / (69 * Math.max(0.1, Math.cos(toRad(origin.lat)))),
  };
}
