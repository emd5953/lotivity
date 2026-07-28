import { useAppStore } from '@/app/store';
import { COMMUNITY_TAGS, FAITH_TAGS } from '@/data/reference/culture';
import { Bubble, BubbleGroup } from '@/ui';
import { toggleIn } from '@/lib/collections';
import { StepFrame } from '../StepFrame';

/**
 * FR-PROF-9. One screen, two headings — faith and community are stored in
 * separate namespaces so they can be matched independently (PRD §9.1).
 * Fully optional: skipping costs nothing (PRD §9.2).
 */
export function CultureStep() {
  const { draft, updateDraft } = useAppStore();
  const toggle = (id: string) => updateDraft({ cultureTags: toggleIn(draft.cultureTags, id) });

  return (
    <StepFrame
      title="Anything you'd want us to match on?"
      subtitle="Optional. It helps us connect you with gatherings organized by and for your community."
      canContinue
      backTo="/welcome/languages"
      nextTo="/welcome/relationship"
      skipTo="/welcome/relationship"
      onNext={() => updateDraft({ step: 6 })}
    >
      <div className="space-y-7">
        <BubbleGroup legend="Faith">
          {FAITH_TAGS.map((tag) => (
            <Bubble
              key={tag.id}
              size="sm"
              label={tag.label}
              selected={draft.cultureTags.includes(tag.id)}
              onToggle={() => toggle(tag.id)}
            />
          ))}
        </BubbleGroup>

        <BubbleGroup legend="Community">
          {COMMUNITY_TAGS.map((tag) => (
            <Bubble
              key={tag.id}
              size="sm"
              label={tag.label}
              selected={draft.cultureTags.includes(tag.id)}
              onToggle={() => toggle(tag.id)}
            />
          ))}
        </BubbleGroup>

        <p className="text-sm leading-relaxed text-muted">
          We never verify or share these as facts about you. They only steer what we show you.
        </p>
      </div>
    </StepFrame>
  );
}
