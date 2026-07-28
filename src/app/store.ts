import { create } from 'zustand';
import type { AccountType, GeoPoint, User } from '@/data/schema';
import { generationFromDob } from '@/lib/generation';
import { DEFAULT_CENTER } from '@/data/reference/nyc';
import { KEYS, clearAll, load, save } from '@/lib/persist';

/** Partial profile captured during onboarding. Persisted on every change. */
export interface OnboardingDraft {
  step: number;
  authMethod?: 'google' | 'apple' | 'guest';
  name: string;
  dob: string;
  accountType?: AccountType;
  heritage: string[];
  languages: string[];
  cultureTags: string[];
  relationshipStatus?: string;
  interests: string[];
  interestSubcategories: string[];
}

export const emptyDraft = (): OnboardingDraft => ({
  step: 0,
  name: '',
  dob: '',
  heritage: [],
  languages: ['English'],
  cultureTags: [],
  interests: [],
  interestSubcategories: [],
});

/**
 * The identity used before anyone signs up. Ranking still works — with no
 * interests or heritage to match, the feed falls back to proximity, which is
 * exactly the "here's what's actually near you" pitch (PRD §9.3).
 */
export const guestProfile = (location: GeoPoint = DEFAULT_CENTER): User => ({
  id: 'user:guest',
  name: 'Guest',
  dob: '',
  generation: 'millennial',
  accountType: 'adult',
  heritage: [],
  languages: ['English'],
  cultureTags: [],
  interests: [],
  interestSubcategories: [],
  location,
  isGuest: true,
});

interface AppState {
  hydrated: boolean;
  profile: User | null;
  draft: OnboardingDraft;
  location: GeoPoint;
  locationLabel: string;

  hydrate: () => Promise<void>;
  updateDraft: (patch: Partial<OnboardingDraft>) => void;
  completeOnboarding: () => Promise<User>;
  setLocation: (point: GeoPoint, label: string) => void;
  resetDemo: () => Promise<void>;
}

export const useAppStore = create<AppState>((set, get) => ({
  hydrated: false,
  profile: null,
  draft: emptyDraft(),
  location: DEFAULT_CENTER,
  locationLabel: 'East Village, Manhattan',

  hydrate: async () => {
    const [profile, draft] = await Promise.all([
      load<User>(KEYS.profile),
      load<OnboardingDraft>(KEYS.draft),
    ]);
    set({
      hydrated: true,
      profile: profile ?? null,
      draft: draft ?? emptyDraft(),
      ...(profile ? { location: profile.location } : {}),
    });
  },

  updateDraft: (patch) => {
    const draft = { ...get().draft, ...patch };
    set({ draft });
    // Fire-and-forget: a refresh mid-flow resumes where it left off (FR-PROF-14).
    void save(KEYS.draft, draft);
  },

  completeOnboarding: async () => {
    const { draft, location } = get();
    const profile: User = {
      id: 'user:me',
      name: draft.name.trim() || 'Guest',
      dob: draft.dob,
      generation: generationFromDob(draft.dob),
      accountType: draft.accountType ?? 'adult',
      heritage: draft.heritage,
      languages: draft.languages,
      cultureTags: draft.cultureTags,
      ...(draft.relationshipStatus ? { relationshipStatus: draft.relationshipStatus } : {}),
      interests: draft.interests,
      interestSubcategories: draft.interestSubcategories,
      location,
      isGuest: draft.authMethod === 'guest',
      ...(draft.accountType === 'youth'
        ? { youthVerification: { status: 'pending' as const } }
        : {}),
    };

    set({ profile });
    await save(KEYS.profile, profile);
    return profile;
  },

  setLocation: (point, label) => set({ location: point, locationLabel: label }),

  resetDemo: async () => {
    await clearAll();
    set({
      profile: null,
      draft: emptyDraft(),
      location: DEFAULT_CENTER,
      locationLabel: 'East Village, Manhattan',
    });
  },
}));
