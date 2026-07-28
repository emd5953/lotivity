import { useAppStore } from '@/app/store';
import { LANGUAGES } from '@/data/reference/culture';
import { Bubble, BubbleGroup } from '@/ui';
import { toggleIn } from '@/lib/collections';
import { StepFrame } from '../StepFrame';

/** FR-PROF-8. */
export function LanguagesStep() {
  const { draft, updateDraft } = useAppStore();

  return (
    <StepFrame
      title="What do you speak?"
      subtitle="Used to surface gatherings held in your languages."
      canContinue
      backTo="/welcome/heritage"
      nextTo="/welcome/culture"
      onNext={() => updateDraft({ step: 5 })}
    >
      <BubbleGroup legend="Languages spoken">
        {LANGUAGES.map((lang) => (
          <Bubble
            key={lang}
            size="sm"
            label={lang}
            selected={draft.languages.includes(lang)}
            onToggle={() => updateDraft({ languages: toggleIn(draft.languages, lang) })}
          />
        ))}
      </BubbleGroup>
    </StepFrame>
  );
}
