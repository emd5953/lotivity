import type { AccountType, Generation } from '@/data/schema';

interface GenerationDef {
  id: Generation;
  label: string;
  /** Inclusive birth-year range. */
  from: number;
  to: number;
}

/** Pew-style boundaries. Generation is shown; the DOB behind it is not (PRD §9.4). */
export const GENERATIONS: GenerationDef[] = [
  { id: 'silent', label: 'Silent Generation', from: 1928, to: 1945 },
  { id: 'boomer', label: 'Baby Boomer', from: 1946, to: 1964 },
  { id: 'genx', label: 'Gen X', from: 1965, to: 1980 },
  { id: 'millennial', label: 'Millennial', from: 1981, to: 1996 },
  { id: 'genz', label: 'Gen Z', from: 1997, to: 2012 },
  { id: 'alpha', label: 'Gen Alpha', from: 2013, to: 2100 },
];

const GENERATION_BY_ID = new Map(GENERATIONS.map((g) => [g.id, g]));

export function generationFromDob(dob: string): Generation {
  const year = new Date(`${dob}T00:00:00`).getUTCFullYear();
  if (Number.isNaN(year)) return 'millennial';
  const match = GENERATIONS.find((g) => year >= g.from && year <= g.to);
  // Anything before the Silent Generation still reads as the oldest cohort.
  return match?.id ?? 'silent';
}

export const generationLabel = (id: Generation): string =>
  GENERATION_BY_ID.get(id)?.label ?? 'Unknown';

export function ageFromDob(dob: string, now: Date = new Date()): number {
  const birth = new Date(`${dob}T00:00:00`);
  let age = now.getFullYear() - birth.getFullYear();
  const monthDiff = now.getMonth() - birth.getMonth();
  if (monthDiff < 0 || (monthDiff === 0 && now.getDate() < birth.getDate())) age -= 1;
  return age;
}

export const ACCOUNT_TYPES: { id: AccountType; label: string; blurb: string }[] = [
  {
    id: 'youth',
    label: 'Youth',
    blurb: 'Events need a community-appointed host or parent who has verified their ID.',
  },
  {
    id: 'adult',
    label: 'General adult',
    blurb: 'Full access to groups, events, and connections in your radius.',
  },
  {
    id: 'retired',
    label: 'Retired',
    blurb: 'Weighted toward recurring, daytime gatherings near you.',
  },
];

/** Suggests an account type from age so the choice starts sensible, not blank. */
export function suggestAccountType(dob: string, now: Date = new Date()): AccountType {
  const age = ageFromDob(dob, now);
  if (age < 18) return 'youth';
  if (age >= 66) return 'retired';
  return 'adult';
}
