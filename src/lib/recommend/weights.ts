/**
 * Single source of tuning (FR-REC-3). Mirrors docs/TECHNICAL_REQUIREMENTS.md §6.
 * Changing ranking behavior should never require touching a call site.
 */
export const WEIGHTS = {
  interestOverlap: 3.0,
  heritageMatch: 2.0,
  cultureMatch: 1.5,
  generationMatch: 1.0,
  proximity: 2.0,
  networkAttendance: 1.0,
  recencyPenalty: 2.0,
} as const;

export type FactorId = keyof typeof WEIGHTS;

/** Feed ranking assumes this radius when the user has not set one. */
export const DEFAULT_FEED_RADIUS_MI = 5;
