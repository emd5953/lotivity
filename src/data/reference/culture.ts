import type { CultureTag } from '@/data/schema';

/**
 * Faith and community are separate namespaces matched independently, but
 * onboarding shows them on one screen under two headings (PRD §9.1).
 * "Hindi" in the original concept notes was a language; the faith is Hindu.
 */
export const FAITH_TAGS: CultureTag[] = [
  { id: 'faith:christian', namespace: 'faith', label: 'Christian' },
  { id: 'faith:catholic', namespace: 'faith', label: 'Catholic' },
  { id: 'faith:jewish', namespace: 'faith', label: 'Jewish' },
  { id: 'faith:muslim', namespace: 'faith', label: 'Muslim' },
  { id: 'faith:hindu', namespace: 'faith', label: 'Hindu' },
  { id: 'faith:buddhist', namespace: 'faith', label: 'Buddhist' },
  { id: 'faith:sikh', namespace: 'faith', label: 'Sikh' },
  { id: 'faith:spiritual', namespace: 'faith', label: 'Spiritual' },
  { id: 'faith:secular', namespace: 'faith', label: 'Secular' },
];

export const COMMUNITY_TAGS: CultureTag[] = [
  { id: 'community:black', namespace: 'community', label: 'Black' },
  { id: 'community:latin', namespace: 'community', label: 'Latin' },
  { id: 'community:arab', namespace: 'community', label: 'Arab' },
  { id: 'community:asian', namespace: 'community', label: 'Asian' },
  { id: 'community:south-asian', namespace: 'community', label: 'South Asian' },
  { id: 'community:caribbean', namespace: 'community', label: 'Caribbean' },
  { id: 'community:african', namespace: 'community', label: 'African' },
  { id: 'community:indigenous', namespace: 'community', label: 'Indigenous' },
  { id: 'community:lgbtq', namespace: 'community', label: 'LGBTQ+' },
  { id: 'community:veteran', namespace: 'community', label: 'Veteran' },
  { id: 'community:newcomer', namespace: 'community', label: 'New to the city' },
];

export const CULTURE_TAGS: CultureTag[] = [...FAITH_TAGS, ...COMMUNITY_TAGS];

export const CULTURE_BY_ID = new Map(CULTURE_TAGS.map((t) => [t.id, t]));

export const cultureLabel = (id: string): string => CULTURE_BY_ID.get(id)?.label ?? id;

export const isFaith = (id: string): boolean => id.startsWith('faith:');

export const RELATIONSHIP_STATUSES = [
  'Single',
  'In a relationship',
  'Married',
  'Partnered',
  'Prefer not to say',
] as const;

export const LANGUAGES = [
  'English',
  'Spanish',
  'Mandarin',
  'Cantonese',
  'French',
  'Haitian Creole',
  'Russian',
  'Arabic',
  'Bengali',
  'Korean',
  'Hindi',
  'Urdu',
  'Yiddish',
  'Hebrew',
  'Italian',
  'Polish',
  'Portuguese',
  'Tagalog',
  'Vietnamese',
  'Japanese',
  'Greek',
  'Albanian',
  'Yoruba',
  'Twi',
  'Amharic',
  'Wolof',
  'Ukrainian',
  'German',
  'Punjabi',
  'Nepali',
] as const;
