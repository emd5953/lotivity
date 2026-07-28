import type { Interest } from '@/data/schema';

const sub = (parent: string, entries: [string, string][]) =>
  entries.map(([id, label]) => ({ id: `${parent}/${id}`, label }));

/** Subcategories per FR-PROF-12. The first six mirror the concept notes. */
export const INTERESTS: Interest[] = [
  {
    id: 'interest:basketball',
    label: 'Basketball',
    emoji: '🏀',
    subcategories: sub('interest:basketball', [
      ['organized', 'Organized play'],
      ['pickup', 'Local pickup'],
      ['outdoor', 'Outside court'],
      ['open-gym', 'Open gym'],
    ]),
  },
  {
    id: 'interest:running',
    label: 'Running',
    emoji: '🏃',
    subcategories: sub('interest:running', [
      ['club', 'Run club'],
      ['trails', 'Trails'],
      ['races', 'Competitions'],
      ['casual', 'Casual jogs'],
    ]),
  },
  {
    id: 'interest:reading',
    label: 'Reading',
    emoji: '📚',
    subcategories: sub('interest:reading', [
      ['workshops', 'Workshops'],
      ['book-clubs', 'Book clubs'],
      ['quiet', 'Quiet places'],
      ['poetry', 'Poetry readings'],
    ]),
  },
  {
    id: 'interest:music',
    label: 'Music',
    emoji: '🎶',
    subcategories: sub('interest:music', [
      ['concerts', 'Concerts'],
      ['open-mic', 'Open mic'],
      ['local-bands', 'Local bands'],
      ['lessons', 'Lessons'],
      ['jazz', 'Jazz'],
      ['hip-hop', 'Hip-hop'],
    ]),
  },
  {
    id: 'interest:pottery',
    label: 'Pottery',
    emoji: '🏺',
    subcategories: sub('interest:pottery', [
      ['wheel', 'Wheel throwing'],
      ['handbuilding', 'Hand building'],
      ['glazing', 'Glazing'],
      ['studio-time', 'Open studio'],
    ]),
  },
  {
    id: 'interest:movies',
    label: 'Movies',
    emoji: '🎬',
    subcategories: sub('interest:movies', [
      ['indie', 'Indie screenings'],
      ['outdoor', 'Outdoor films'],
      ['classics', 'Classics'],
      ['discussion', 'Film discussion'],
    ]),
  },
  {
    id: 'interest:cooking',
    label: 'Cooking',
    emoji: '🍳',
    subcategories: sub('interest:cooking', [
      ['classes', 'Classes'],
      ['potlucks', 'Potlucks'],
      ['baking', 'Baking'],
      ['heritage', 'Heritage recipes'],
    ]),
  },
  {
    id: 'interest:volunteering',
    label: 'Volunteering',
    emoji: '🤝',
    subcategories: sub('interest:volunteering', [
      ['food', 'Food programs'],
      ['parks', 'Parks & cleanups'],
      ['mentoring', 'Mentoring'],
      ['seniors', 'Senior support'],
    ]),
  },
  {
    id: 'interest:soccer',
    label: 'Soccer',
    emoji: '⚽',
    subcategories: sub('interest:soccer', [
      ['pickup', 'Pickup'],
      ['league', 'League play'],
      ['watch', 'Watch parties'],
    ]),
  },
  {
    id: 'interest:art',
    label: 'Art',
    emoji: '🎨',
    subcategories: sub('interest:art', [
      ['galleries', 'Galleries'],
      ['drawing', 'Drawing sessions'],
      ['murals', 'Public murals'],
      ['crafts', 'Crafts'],
    ]),
  },
  {
    id: 'interest:yoga',
    label: 'Yoga',
    emoji: '🧘',
    subcategories: sub('interest:yoga', [
      ['studio', 'Studio classes'],
      ['park', 'In the park'],
      ['gentle', 'Gentle & restorative'],
    ]),
  },
  {
    id: 'interest:chess',
    label: 'Chess',
    emoji: '♟️',
    subcategories: sub('interest:chess', [
      ['park', 'Park tables'],
      ['club', 'Chess club'],
      ['tournaments', 'Tournaments'],
    ]),
  },
  {
    id: 'interest:dance',
    label: 'Dance',
    emoji: '💃',
    subcategories: sub('interest:dance', [
      ['salsa', 'Salsa & bachata'],
      ['afrobeats', 'Afrobeats'],
      ['ballroom', 'Ballroom'],
      ['classes', 'Classes'],
    ]),
  },
  {
    id: 'interest:gardening',
    label: 'Gardening',
    emoji: '🌿',
    subcategories: sub('interest:gardening', [
      ['community-plot', 'Community plots'],
      ['workshops', 'Workshops'],
      ['seed-swap', 'Seed swaps'],
    ]),
  },
  {
    id: 'interest:cycling',
    label: 'Cycling',
    emoji: '🚲',
    subcategories: sub('interest:cycling', [
      ['group-rides', 'Group rides'],
      ['commuting', 'Commuting'],
      ['repair', 'Repair clinics'],
    ]),
  },
  {
    id: 'interest:photography',
    label: 'Photography',
    emoji: '📷',
    subcategories: sub('interest:photography', [
      ['walks', 'Photo walks'],
      ['film', 'Film & darkroom'],
      ['critique', 'Critique nights'],
    ]),
  },
];

export const INTEREST_BY_ID = new Map(INTERESTS.map((i) => [i.id, i]));

export const interestLabel = (id: string): string => INTEREST_BY_ID.get(id)?.label ?? id;

export const REQUIRED_INTEREST_COUNT = 6;
