import { useAppStore } from '@/app/store';
import { INTERESTS, INTEREST_BY_ID, REQUIRED_INTEREST_COUNT } from '@/data/reference/interests';
import { Bubble, BubbleGroup } from '@/ui';
import { toggleIn } from '@/lib/collections';
import { StepFrame } from '../StepFrame';

/**
 * FR-PROF-11 (exactly 6 to proceed) and FR-PROF-12 (subcategories, optional).
 */
export function InterestsStep() {
  const { draft, updateDraft } = useAppStore();
  const chosen = draft.interests;
  const atLimit = chosen.length >= REQUIRED_INTEREST_COUNT;
  const remaining = REQUIRED_INTEREST_COUNT - chosen.length;

  const toggleInterest = (id: string) => {
    const next = toggleIn(chosen, id);
    if (next.length > REQUIRED_INTEREST_COUNT) return;
    // Drop orphaned subcategories when an interest is removed.
    const kept = draft.interestSubcategories.filter((sub) =>
      next.some((interestId) => sub.startsWith(`${interestId}/`)),
    );
    updateDraft({ interests: next, interestSubcategories: kept });
  };

  return (
    <StepFrame
      title="Pick 6 things you're into"
      subtitle="You can add more later. These do the heavy lifting in what we show you."
      canContinue={chosen.length === REQUIRED_INTEREST_COUNT}
      backTo="/welcome/relationship"
      nextTo="/welcome/rendering"
      onNext={() => updateDraft({ step: 8 })}
      blockedHint={
        remaining > 0
          ? `Choose ${remaining} more.`
          : undefined
      }
    >
      <div className="space-y-7">
        <BubbleGroup
          legend="Interests"
          hideLegend
          description={`${chosen.length} of ${REQUIRED_INTEREST_COUNT} selected`}
        >
          {INTERESTS.map((interest) => {
            const selected = chosen.includes(interest.id);
            return (
              <Bubble
                key={interest.id}
                label={
                  <>
                    <span aria-hidden="true">{interest.emoji}</span>
                    {interest.label}
                  </>
                }
                selected={selected}
                disabled={!selected && atLimit}
                onToggle={() => toggleInterest(interest.id)}
              />
            );
          })}
        </BubbleGroup>

        {chosen.length > 0 ? (
          <div className="mt-2 space-y-5 pt-6 shadow-[inset_0_1px_0_0_rgb(var(--c-cream)/0.09)]">
            <p className="text-sm text-cream/45">
              Want to narrow any of these? Optional, but it sharpens your feed.
            </p>
            {chosen.map((id) => {
              const interest = INTEREST_BY_ID.get(id);
              if (!interest) return null;
              return (
                <BubbleGroup key={id} legend={interest.label}>
                  {interest.subcategories.map((sub) => (
                    <Bubble
                      key={sub.id}
                      size="sm"
                      label={sub.label}
                      selected={draft.interestSubcategories.includes(sub.id)}
                      onToggle={() =>
                        updateDraft({
                          interestSubcategories: toggleIn(draft.interestSubcategories, sub.id),
                        })
                      }
                    />
                  ))}
                </BubbleGroup>
              );
            })}
          </div>
        ) : null}
      </div>
    </StepFrame>
  );
}
