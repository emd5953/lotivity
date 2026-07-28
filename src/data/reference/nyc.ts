import type { GeoPoint } from '@/data/schema';

/**
 * Real NYC neighborhood centers so radius changes behave plausibly.
 * Venue names in the fixtures are fictional (PRD §9.5).
 */
export interface Neighborhood {
  id: string;
  name: string;
  borough: 'Manhattan' | 'Brooklyn' | 'Queens' | 'Bronx';
  center: GeoPoint;
}

export const NEIGHBORHOODS: Neighborhood[] = [
  { id: 'les', name: 'Lower East Side', borough: 'Manhattan', center: { lat: 40.715, lng: -73.9857 } },
  { id: 'ev', name: 'East Village', borough: 'Manhattan', center: { lat: 40.7265, lng: -73.9815 } },
  { id: 'wv', name: 'West Village', borough: 'Manhattan', center: { lat: 40.7358, lng: -74.0036 } },
  { id: 'chelsea', name: 'Chelsea', borough: 'Manhattan', center: { lat: 40.7465, lng: -74.0014 } },
  { id: 'hk', name: "Hell's Kitchen", borough: 'Manhattan', center: { lat: 40.7638, lng: -73.9918 } },
  { id: 'uws', name: 'Upper West Side', borough: 'Manhattan', center: { lat: 40.787, lng: -73.9754 } },
  { id: 'ues', name: 'Upper East Side', borough: 'Manhattan', center: { lat: 40.7736, lng: -73.9566 } },
  { id: 'harlem', name: 'Harlem', borough: 'Manhattan', center: { lat: 40.8116, lng: -73.9465 } },
  { id: 'wash-heights', name: 'Washington Heights', borough: 'Manhattan', center: { lat: 40.8417, lng: -73.9394 } },
  { id: 'inwood', name: 'Inwood', borough: 'Manhattan', center: { lat: 40.8677, lng: -73.9212 } },
  { id: 'wburg', name: 'Williamsburg', borough: 'Brooklyn', center: { lat: 40.7143, lng: -73.9613 } },
  { id: 'bushwick', name: 'Bushwick', borough: 'Brooklyn', center: { lat: 40.6944, lng: -73.9213 } },
  { id: 'bedstuy', name: 'Bedford-Stuyvesant', borough: 'Brooklyn', center: { lat: 40.6872, lng: -73.9418 } },
  { id: 'ftgreene', name: 'Fort Greene', borough: 'Brooklyn', center: { lat: 40.6892, lng: -73.9742 } },
  { id: 'parkslope', name: 'Park Slope', borough: 'Brooklyn', center: { lat: 40.6710, lng: -73.9814 } },
  { id: 'crownhts', name: 'Crown Heights', borough: 'Brooklyn', center: { lat: 40.6694, lng: -73.9442 } },
  { id: 'sunsetpark', name: 'Sunset Park', borough: 'Brooklyn', center: { lat: 40.6454, lng: -74.0122 } },
  { id: 'flatbush', name: 'Flatbush', borough: 'Brooklyn', center: { lat: 40.6409, lng: -73.9624 } },
  { id: 'astoria', name: 'Astoria', borough: 'Queens', center: { lat: 40.7644, lng: -73.9235 } },
  { id: 'lic', name: 'Long Island City', borough: 'Queens', center: { lat: 40.7447, lng: -73.9485 } },
  { id: 'jacksonhts', name: 'Jackson Heights', borough: 'Queens', center: { lat: 40.7557, lng: -73.8831 } },
  { id: 'flushing', name: 'Flushing', borough: 'Queens', center: { lat: 40.7674, lng: -73.833 } },
  { id: 'jamaica', name: 'Jamaica', borough: 'Queens', center: { lat: 40.7027, lng: -73.7889 } },
  { id: 'sunnyside', name: 'Sunnyside', borough: 'Queens', center: { lat: 40.7433, lng: -73.9196 } },
  { id: 'mott-haven', name: 'Mott Haven', borough: 'Bronx', center: { lat: 40.809, lng: -73.9229 } },
  { id: 'fordham', name: 'Fordham', borough: 'Bronx', center: { lat: 40.8618, lng: -73.8905 } },
];

export const NEIGHBORHOOD_BY_ID = new Map(NEIGHBORHOODS.map((n) => [n.id, n]));

/** Fallback center when geolocation is denied or unavailable (FR-MAP-6). */
export const DEFAULT_CENTER: GeoPoint = { lat: 40.7295, lng: -73.9665 };
export const DEFAULT_CENTER_LABEL = 'East Village, Manhattan';

/** Rough bounds used to decide whether a real geolocation fix is usable. */
export const NYC_BOUNDS = {
  minLat: 40.47,
  maxLat: 40.93,
  minLng: -74.27,
  maxLng: -73.68,
};

export const isWithinNyc = (p: GeoPoint): boolean =>
  p.lat >= NYC_BOUNDS.minLat &&
  p.lat <= NYC_BOUNDS.maxLat &&
  p.lng >= NYC_BOUNDS.minLng &&
  p.lng <= NYC_BOUNDS.maxLng;
