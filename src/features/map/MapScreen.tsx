import { useEffect, useMemo, useRef, useState } from 'react';
import maplibregl, { type Map as MapLibreMap, type Marker } from 'maplibre-gl';
import 'maplibre-gl/dist/maplibre-gl.css';
import { useAppStore } from '@/app/store';
import { getMapItems, getNetworkTrail, type MapItem } from '@/data/repo';
import type { MapFilter } from '@/data/schema';
import { DEFAULT_CENTER, DEFAULT_CENTER_LABEL, isWithinNyc } from '@/data/reference/nyc';
import { boundsForRadius } from '@/lib/geo';
import { Bubble, BubbleGroup, Button, Sheet } from '@/ui';

/** No API key required — swap this one constant for Mapbox later. Dark, because
 *  there is no light mode and a bright basemap would be the only lit object. */
const BASEMAP_STYLE = 'https://basemaps.cartocdn.com/gl/dark-matter-gl-style/style.json';

const FILTERS: { id: MapFilter; label: string }[] = [
  { id: 'events', label: 'Events' },
  { id: 'clubs', label: 'Clubs' },
  { id: 'workshops', label: 'Workshops' },
  { id: 'food', label: 'Food' },
];

const RADII = [0.5, 1, 2, 5, 10];

/**
 * The categorical palette (DESIGN_SPEC §1.5) — muted so a dense map still
 * reads as Lotivity. Olive is absent on purpose: it means "alive", not
 * "category". No orange, ever.
 */
const PIN_COLORS: Record<MapFilter, string> = {
  events: '#7E8F5A', // moss
  clubs: '#8892A0', // slate
  workshops: '#9B7FA6', // plum
  food: '#C9B08A', // sand
};

export function MapScreen() {
  const { location, locationLabel, setLocation, profile } = useAppStore();

  const [radiusMi, setRadiusMi] = useState(2);
  const [filters, setFilters] = useState<MapFilter[]>(['events', 'clubs', 'workshops', 'food']);
  const [items, setItems] = useState<MapItem[]>([]);
  const [trail, setTrail] = useState<MapItem[]>([]);
  const [showTrail, setShowTrail] = useState(false);
  const [selected, setSelected] = useState<MapItem | null>(null);
  const [geoDenied, setGeoDenied] = useState(false);
  const [tilesFailed, setTilesFailed] = useState(false);

  const containerRef = useRef<HTMLDivElement | null>(null);
  const mapRef = useRef<MapLibreMap | null>(null);
  const markersRef = useRef<Marker[]>([]);

  // Geolocation with a stated reason; denial is a soft landing (FR-MAP-6).
  useEffect(() => {
    if (!navigator.geolocation) return;
    navigator.geolocation.getCurrentPosition(
      (pos) => {
        const point = { lat: pos.coords.latitude, lng: pos.coords.longitude };
        // The fixture world is NYC-only; a real fix elsewhere would show an
        // empty map, which reads as broken rather than as "you're not in NYC".
        if (isWithinNyc(point)) setLocation(point, 'Your location');
        else setGeoDenied(true);
      },
      () => setGeoDenied(true),
      { timeout: 5000 },
    );
  }, [setLocation]);

  useEffect(() => {
    if (!containerRef.current || mapRef.current) return;

    const map = new maplibregl.Map({
      container: containerRef.current,
      style: BASEMAP_STYLE,
      center: [location.lng, location.lat],
      zoom: 13,
      attributionControl: { compact: true },
    });

    map.on('error', (e) => {
      // Offline or blocked tiles: keep pins usable over a blank canvas (NFR-9).
      if (e?.error?.message?.includes('style')) setTilesFailed(true);
    });

    mapRef.current = map;
    return () => {
      map.remove();
      mapRef.current = null;
    };
    // Only construct once; recentering is handled below.
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  useEffect(() => {
    let cancelled = false;
    void (async () => {
      const [nearby, networkTrail] = await Promise.all([
        getMapItems({ center: location, radiusMi, filters }),
        profile ? getNetworkTrail('user:1') : Promise.resolve([]),
      ]);
      if (!cancelled) {
        setItems(nearby);
        setTrail(networkTrail);
      }
    })();
    return () => {
      cancelled = true;
    };
  }, [location, radiusMi, filters, profile]);

  // Repaint markers whenever the visible set changes.
  useEffect(() => {
    const map = mapRef.current;
    if (!map) return;

    markersRef.current.forEach((m) => m.remove());
    markersRef.current = [];

    const visible = showTrail ? [...items, ...trail] : items;
    for (const item of visible) {
      const el = document.createElement('button');
      el.type = 'button';
      el.setAttribute('aria-label', item.title);
      // An ink ring, not a white one — pins separate from each other by a
      // luminance step, the same as everything else in the system.
      el.style.cssText = `width:14px;height:14px;border-radius:999px;border:2px solid #0A0A0A;cursor:pointer;background:${PIN_COLORS[item.filter]};box-shadow:0 1px 6px rgba(0,0,0,.6)`;
      el.addEventListener('click', () => setSelected(item));

      markersRef.current.push(
        new maplibregl.Marker({ element: el })
          .setLngLat([item.location.lng, item.location.lat])
          .addTo(map),
      );
    }
  }, [items, trail, showTrail]);

  // Keep the viewport matched to the radius so the control feels connected.
  useEffect(() => {
    const map = mapRef.current;
    if (!map) return;
    const [sw, ne] = boundsForRadius(location, radiusMi);
    map.fitBounds(
      [
        [sw.lng, sw.lat],
        [ne.lng, ne.lat],
      ],
      { padding: 40, duration: 400 },
    );
  }, [location, radiusMi]);

  const counts = useMemo(() => {
    const byFilter = new Map<MapFilter, number>();
    for (const item of items) byFilter.set(item.filter, (byFilter.get(item.filter) ?? 0) + 1);
    return byFilter;
  }, [items]);

  return (
    <div className="pt-6">
      <div className="flex items-baseline justify-between gap-3">
        <h1 className="text-[1.875rem] font-semibold leading-none tracking-display text-cream">
          Around you
        </h1>
        <p className="chip-label shrink-0 text-cream/45 tabular-nums" aria-live="polite">
          {items.length} within {radiusMi} mi
        </p>
      </div>
      <p className="mt-2.5 text-sm text-cream/45">
        {geoDenied ? `Showing ${DEFAULT_CENTER_LABEL}` : locationLabel}
      </p>

      <div
        ref={containerRef}
        className="relative mt-4 h-[46vh] w-full overflow-hidden rounded-card bg-soft ring-1 ring-inset ring-cream/7"
      >
        {tilesFailed ? (
          <p className="eyebrow absolute inset-x-0 top-3 z-10 text-center">
            Offline — showing pins without the basemap
          </p>
        ) : null}
      </div>

      <div className="mt-4 space-y-4">
        <BubbleGroup legend="Show">
          {FILTERS.map((f) => (
            <Bubble
              key={f.id}
              size="sm"
              label={`${f.label}${counts.get(f.id) ? ` (${counts.get(f.id)})` : ''}`}
              selected={filters.includes(f.id)}
              onToggle={() =>
                setFilters((prev) =>
                  prev.includes(f.id) ? prev.filter((x) => x !== f.id) : [...prev, f.id],
                )
              }
            />
          ))}
        </BubbleGroup>

        <div>
          <label htmlFor="radius" className="eyebrow mb-2.5 block tabular-nums">
            Radius — {radiusMi} mi
          </label>
          <input
            id="radius"
            type="range"
            min={0}
            max={RADII.length - 1}
            step={1}
            value={RADII.indexOf(radiusMi)}
            onChange={(e) => setRadiusMi(RADII[Number(e.target.value)] ?? 2)}
            className="w-full accent-accent"
          />
          <div className="flex justify-between font-mono text-[0.65rem] tabular-nums text-cream/30">
            {RADII.map((r) => (
              <span key={r}>{r}</span>
            ))}
          </div>
        </div>

        <Bubble
          size="sm"
          label={`Where my network has been${trail.length ? ` (${trail.length})` : ''}`}
          selected={showTrail}
          onToggle={() => setShowTrail((v) => !v)}
        />

        {geoDenied ? (
          <p className="surface-card p-4 text-sm leading-relaxed text-cream/45">
            We couldn&rsquo;t use your location, so you&rsquo;re seeing {DEFAULT_CENTER_LABEL}.
            Everything still works — drag the map to look around.
          </p>
        ) : null}

        <Button
          variant="secondary"
          full
          onClick={() => setLocation(DEFAULT_CENTER, DEFAULT_CENTER_LABEL)}
        >
          Recenter
        </Button>
      </div>

      <Sheet open={Boolean(selected)} onClose={() => setSelected(null)} title={selected?.title ?? ''}>
        {selected ? (
          <>
            <p className="eyebrow">{selected.kind}</p>
            <h2 className="mt-1.5 text-xl font-semibold tracking-title text-cream">
              {selected.title}
            </h2>
            <p className="mt-1 text-sm text-cream/45">{selected.subtitle}</p>
            <p className="mt-3 font-mono text-sm tabular-nums text-cream/60">
              {selected.distanceMi.toFixed(1)} mi away
            </p>
          </>
        ) : null}
      </Sheet>
    </div>
  );
}
