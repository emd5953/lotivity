import { clear, del, get, set } from 'idb-keyval';

/**
 * IndexedDB wrapper. Chosen over localStorage because voice-memo blobs land
 * here in M6 and would blow the localStorage quota.
 */
export const KEYS = {
  profile: 'lotivity:profile',
  draft: 'lotivity:onboarding-draft',
  seen: 'lotivity:seen-events',
  mapPrefs: 'lotivity:map-prefs',
} as const;

export async function load<T>(key: string): Promise<T | undefined> {
  try {
    return await get<T>(key);
  } catch {
    // Private browsing and some embedded webviews block IndexedDB entirely.
    // Losing persistence is acceptable; crashing the app is not (NFR-8).
    return undefined;
  }
}

export async function save<T>(key: string, value: T): Promise<void> {
  try {
    await set(key, value);
  } catch {
    /* non-fatal — see load() */
  }
}

export async function remove(key: string): Promise<void> {
  try {
    await del(key);
  } catch {
    /* non-fatal */
  }
}

/** Backs the "Reset demo" control (FR-APP-5). */
export async function clearAll(): Promise<void> {
  try {
    await clear();
  } catch {
    /* non-fatal */
  }
}
