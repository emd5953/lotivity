/**
 * Domain types — the contract between features and the repository layer.
 * Mirrors docs/TECHNICAL_REQUIREMENTS.md §5. A future API returns these shapes
 * unchanged, so nothing here may depend on how fixtures happen to be stored.
 */

export type ID = string;

export type Generation = 'alpha' | 'genz' | 'millennial' | 'genx' | 'boomer' | 'silent';
export type AccountType = 'youth' | 'adult' | 'retired';

export type Continent =
  | 'africa'
  | 'asia'
  | 'europe'
  | 'north-america'
  | 'oceania'
  | 'south-america';

export type EventCategory = 'sports' | 'paid' | 'volunteer' | 'social' | 'work';

/** Map filter buckets (FR-MAP-2) — a projection of category + entity kind. */
export type MapFilter = 'events' | 'clubs' | 'workshops' | 'food';

export interface GeoPoint {
  lat: number;
  lng: number;
}

export interface Heritage {
  id: ID;
  label: string;
  continent: Continent;
  country: string;
}

export interface InterestSubcategory {
  id: ID;
  label: string;
}

export interface Interest {
  id: ID;
  label: string;
  emoji: string;
  subcategories: InterestSubcategory[];
}

/**
 * Culture tags are namespaced (PRD §9.1): `faith:*` and `community:*` are
 * matched independently even though onboarding presents them on one screen.
 */
export type CultureNamespace = 'faith' | 'community';

export interface CultureTag {
  id: ID; // e.g. "faith:christian", "community:latin"
  namespace: CultureNamespace;
  label: string;
}

export interface YouthVerification {
  status: 'none' | 'pending' | 'verified';
  guardianName?: string;
}

/** Full user record. Only ever leaves the repo layer as PublicUser. */
export interface User {
  id: ID;
  name: string;
  /** ISO date. Never exposed to other users (FR-PROF-2, BR-5). */
  dob: string;
  /** Derived from dob — the only age signal shown to others. */
  generation: Generation;
  accountType: AccountType;
  heritage: ID[];
  languages: string[];
  cultureTags: ID[];
  relationshipStatus?: string;
  interests: ID[];
  interestSubcategories: ID[];
  location: GeoPoint;
  isGuest: boolean;
  youthVerification?: YouthVerification;
}

/** What any other user is allowed to see. Note the absence of `dob`. */
export type PublicUser = Omit<User, 'dob'>;

export interface Business {
  id: ID;
  name: string;
  category: string;
  /** Which map filter bucket this business falls into. */
  mapFilter: Extract<MapFilter, 'food' | 'workshops'>;
  location: GeoPoint;
  neighborhood: string;
  /** Matched against group requests (PRD §5.2). Self-declared — see PRD §10 Q5. */
  valueTags: ID[];
  inNetwork: boolean;
  positiveVotes7d: number;
}

export interface LotivityEvent {
  id: ID;
  title: string;
  hostId: ID;
  hostType: 'user' | 'group' | 'business';
  category: EventCategory;
  location: GeoPoint;
  neighborhood: string;
  venueId?: ID;
  startsAt: string;
  endsAt: string;
  interestTags: ID[];
  heritageTags: ID[];
  cultureTags: ID[];
  generationTags: Generation[];
  attendeeIds: ID[];
  interestedIds: ID[];
  /** True when youth accounts may attend — implies a verified adult (FR-PROF-6). */
  requiresGuardian: boolean;
  sponsoredBy?: ID;
  priceLabel?: string;
}

export interface Sponsorship {
  state: 'none' | 'pending' | 'sponsored';
  businessId?: ID;
  promoCode?: string;
}

export interface Group {
  id: ID;
  name: string;
  category: EventCategory;
  description: string;
  memberIds: ID[];
  radiusMi: number;
  center: GeoPoint;
  neighborhood: string;
  interestTags: ID[];
  cultureTags: ID[];
  sponsorship: Sponsorship;
}

export interface ActivityRequest {
  id: ID;
  authorId: ID;
  description: string;
  radiusMi: number;
  center: GeoPoint;
  targetInterests: ID[];
  targetCulture: ID[];
  targetGenerations: Generation[];
  /** Simulated in v0 — no notifications are actually sent. */
  notifiedCount: number;
  upvotes: number;
  upvoteThreshold: number;
  resolvedGroupId?: ID;
}

export interface MediaRef {
  id: ID;
  kind: 'image';
  /** Fixture art is generated, not fetched — see lib/art. */
  seed: string;
  alt: string;
}

export interface VoiceMemo {
  blobKey: string;
  durationSec: number;
  sentiment: 'positive' | 'neutral' | 'negative';
}

export interface Post {
  id: ID;
  authorId: ID;
  eventId?: ID;
  businessId?: ID;
  body: string;
  media: MediaRef[];
  voiceMemo?: VoiceMemo;
  createdAt: string;
  /** Enforces the 7-day event-post window (FR-SOCIAL-2). */
  visibleUntil: string;
}

export interface Connection {
  userId: ID;
  peerId: ID;
  origin: 'invite' | 'contacts' | 'shared-event';
  sharedEventId?: ID;
  connectedAt: string;
}
