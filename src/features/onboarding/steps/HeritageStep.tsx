import { useMemo, useState } from 'react';
import { useAppStore } from '@/app/store';
import {
  CONTINENT_LABELS,
  CONTINENT_ORDER,
  HERITAGES,
  heritagesByContinent,
} from '@/data/reference/heritage';
import { Bubble, BubbleGroup } from '@/ui';
import { toggleIn } from '@/lib/collections';
import { StepFrame } from '../StepFrame';

const HOME_HERITAGE = 'heritage:united-states';

/** FR-PROF-7. Country of location is pre-filled; the rest nests by continent. */
export function HeritageStep() {
  const { draft, updateDraft } = useAppStore();
  const [query, setQuery] = useState('');

  const selected = draft.heritage.length > 0 ? draft.heritage : [HOME_HERITAGE];

  const matches = useMemo(() => {
    const q = query.trim().toLowerCase();
    if (!q) return null;
    return HERITAGES.filter(
      (h) => h.label.toLowerCase().includes(q) || h.country.toLowerCase().includes(q),
    );
  }, [query]);

  const toggle = (id: string) => updateDraft({ heritage: toggleIn(selected, id) });

  return (
    <StepFrame
      title="Where's your family from?"
      subtitle="This drives the local events and heritage nights we surface for you. Pick as many as fit."
      canContinue
      backTo="/welcome/account-type"
      nextTo="/welcome/languages"
      onNext={() => updateDraft({ heritage: selected, step: 4 })}
    >
      <div className="space-y-6">
        <input
          type="search"
          value={query}
          onChange={(e) => setQuery(e.target.value)}
          placeholder="Search heritage"
          aria-label="Search heritage"
          className="w-full rounded-card border border-line bg-surface px-4 py-3 placeholder:text-muted/60"
        />

        {matches ? (
          <BubbleGroup legend="Search results">
            {matches.length === 0 ? (
              <p className="text-sm text-muted">No matches for &ldquo;{query}&rdquo;.</p>
            ) : (
              matches.map((h) => (
                <Bubble
                  key={h.id}
                  size="sm"
                  label={h.label}
                  selected={selected.includes(h.id)}
                  onToggle={() => toggle(h.id)}
                />
              ))
            )}
          </BubbleGroup>
        ) : (
          CONTINENT_ORDER.map((continent) => (
            <BubbleGroup key={continent} legend={CONTINENT_LABELS[continent]}>
              {heritagesByContinent(continent).map((h) => (
                <Bubble
                  key={h.id}
                  size="sm"
                  label={h.label}
                  selected={selected.includes(h.id)}
                  onToggle={() => toggle(h.id)}
                />
              ))}
            </BubbleGroup>
          ))
        )}
      </div>
    </StepFrame>
  );
}
