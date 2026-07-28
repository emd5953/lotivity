/** Adds or removes an id — the shared behavior behind every multi-select. */
export function toggleIn(list: string[], id: string): string[] {
  return list.includes(id) ? list.filter((x) => x !== id) : [...list, id];
}
