import type { Continent, Heritage } from '@/data/schema';

export const CONTINENT_LABELS: Record<Continent, string> = {
  'north-america': 'North America',
  'south-america': 'South America',
  europe: 'Europe',
  africa: 'Africa',
  asia: 'Asia',
  oceania: 'Oceania',
};

export const CONTINENT_ORDER: Continent[] = [
  'north-america',
  'south-america',
  'europe',
  'africa',
  'asia',
  'oceania',
];

const build = (continent: Continent, entries: [string, string][]): Heritage[] =>
  entries.map(([country, label]) => ({
    id: `heritage:${country.toLowerCase().replace(/\s+/g, '-')}`,
    label,
    continent,
    country,
  }));

/** ≥8 options per continent (FR-PROF-7). */
export const HERITAGES: Heritage[] = [
  ...build('north-america', [
    ['United States', 'American'],
    ['Mexico', 'Mexican'],
    ['Canada', 'Canadian'],
    ['Jamaica', 'Jamaican'],
    ['Haiti', 'Haitian'],
    ['Dominican Republic', 'Dominican'],
    ['Puerto Rico', 'Puerto Rican'],
    ['Cuba', 'Cuban'],
    ['Guatemala', 'Guatemalan'],
    ['Trinidad and Tobago', 'Trinidadian'],
  ]),
  ...build('south-america', [
    ['Brazil', 'Brazilian'],
    ['Colombia', 'Colombian'],
    ['Argentina', 'Argentine'],
    ['Peru', 'Peruvian'],
    ['Venezuela', 'Venezuelan'],
    ['Ecuador', 'Ecuadorian'],
    ['Chile', 'Chilean'],
    ['Bolivia', 'Bolivian'],
    ['Uruguay', 'Uruguayan'],
  ]),
  ...build('europe', [
    ['Ireland', 'Irish'],
    ['Italy', 'Italian'],
    ['Poland', 'Polish'],
    ['Germany', 'German'],
    ['Greece', 'Greek'],
    ['Portugal', 'Portuguese'],
    ['Ukraine', 'Ukrainian'],
    ['France', 'French'],
    ['Spain', 'Spanish'],
    ['United Kingdom', 'British'],
    ['Albania', 'Albanian'],
  ]),
  ...build('africa', [
    ['Nigeria', 'Nigerian'],
    ['Tanzania', 'Tanzanian'],
    ['Ghana', 'Ghanaian'],
    ['Ethiopia', 'Ethiopian'],
    ['Kenya', 'Kenyan'],
    ['Senegal', 'Senegalese'],
    ['Egypt', 'Egyptian'],
    ['Morocco', 'Moroccan'],
    ['South Africa', 'South African'],
    ['Somalia', 'Somali'],
  ]),
  ...build('asia', [
    ['China', 'Chinese'],
    ['South Korea', 'South Korean'],
    ['India', 'Indian'],
    ['Philippines', 'Filipino'],
    ['Japan', 'Japanese'],
    ['Vietnam', 'Vietnamese'],
    ['Pakistan', 'Pakistani'],
    ['Bangladesh', 'Bangladeshi'],
    ['Lebanon', 'Lebanese'],
    ['Nepal', 'Nepali'],
  ]),
  ...build('oceania', [
    ['Australia', 'Australian'],
    ['New Zealand', 'New Zealander'],
    ['Samoa', 'Samoan'],
    ['Fiji', 'Fijian'],
    ['Tonga', 'Tongan'],
    ['Papua New Guinea', 'Papua New Guinean'],
    ['Guam', 'Chamorro'],
    ['Hawaii', 'Native Hawaiian'],
  ]),
];

export const HERITAGE_BY_ID = new Map(HERITAGES.map((h) => [h.id, h]));

export const heritagesByContinent = (continent: Continent): Heritage[] =>
  HERITAGES.filter((h) => h.continent === continent);

export const heritageLabel = (id: string): string => HERITAGE_BY_ID.get(id)?.label ?? id;
