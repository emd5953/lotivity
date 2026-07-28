import { describe, expect, it } from 'vitest';
import { ageFromDob, generationFromDob, suggestAccountType } from './index';

describe('generationFromDob', () => {
  it('maps each cohort at its boundaries', () => {
    // Boundary years are where an off-by-one would hide.
    expect(generationFromDob('1945-12-31')).toBe('silent');
    expect(generationFromDob('1946-01-01')).toBe('boomer');
    expect(generationFromDob('1964-12-31')).toBe('boomer');
    expect(generationFromDob('1965-01-01')).toBe('genx');
    expect(generationFromDob('1980-12-31')).toBe('genx');
    expect(generationFromDob('1981-01-01')).toBe('millennial');
    expect(generationFromDob('1996-12-31')).toBe('millennial');
    expect(generationFromDob('1997-01-01')).toBe('genz');
    expect(generationFromDob('2012-12-31')).toBe('genz');
    expect(generationFromDob('2013-01-01')).toBe('alpha');
  });

  it('treats anyone older than the Silent Generation as the oldest cohort', () => {
    expect(generationFromDob('1910-05-05')).toBe('silent');
  });

  it('falls back rather than throwing on unparseable input', () => {
    expect(generationFromDob('')).toBe('millennial');
  });
});

describe('ageFromDob', () => {
  const now = new Date('2026-07-28T12:00:00Z');

  it('does not count a birthday that has not happened yet this year', () => {
    expect(ageFromDob('2000-07-29', now)).toBe(25);
    expect(ageFromDob('2000-07-28', now)).toBe(26);
  });
});

describe('suggestAccountType', () => {
  const now = new Date('2026-07-28T12:00:00Z');

  it('routes by age band', () => {
    expect(suggestAccountType('2012-01-01', now)).toBe('youth');
    expect(suggestAccountType('1995-01-01', now)).toBe('adult');
    expect(suggestAccountType('1950-01-01', now)).toBe('retired');
  });
});
