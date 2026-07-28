/**
 * Deterministic PRNG (mulberry32). Fixtures must be identical on every machine
 * so tests are stable and the demo looks the same everywhere.
 */
export function createRng(seed: number) {
  let a = seed >>> 0;

  const next = (): number => {
    a = (a + 0x6d2b79f5) >>> 0;
    let t = a;
    t = Math.imul(t ^ (t >>> 15), t | 1);
    t ^= t + Math.imul(t ^ (t >>> 7), t | 61);
    return ((t ^ (t >>> 14)) >>> 0) / 4294967296;
  };

  const int = (minInclusive: number, maxInclusive: number): number =>
    minInclusive + Math.floor(next() * (maxInclusive - minInclusive + 1));

  const pick = <T>(items: readonly T[]): T => {
    if (items.length === 0) throw new Error('pick() called with an empty list');
    return items[int(0, items.length - 1)] as T;
  };

  /** n distinct items, or all of them if n exceeds the list length. */
  const sample = <T>(items: readonly T[], n: number): T[] => {
    const pool = [...items];
    const out: T[] = [];
    const count = Math.min(n, pool.length);
    for (let i = 0; i < count; i += 1) {
      const idx = int(0, pool.length - 1);
      out.push(pool.splice(idx, 1)[0] as T);
    }
    return out;
  };

  const chance = (probability: number): boolean => next() < probability;

  /** Float in [min, max). */
  const float = (min: number, max: number): number => min + next() * (max - min);

  return { next, int, pick, sample, chance, float };
}

export type Rng = ReturnType<typeof createRng>;
