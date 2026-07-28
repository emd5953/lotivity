import { useAppStore } from '@/app/store';
import { RELATIONSHIP_STATUSES } from '@/data/reference/culture';
import { Bubble, BubbleGroup } from '@/ui';
import { StepFrame } from '../StepFrame';

/** FR-PROF-10. Optional, and explicitly not a dating signal (PRD §11). */
export function RelationshipStep() {
  const { draft, updateDraft } = useAppStore();

  return (
    <StepFrame
      title="Relationship status"
      subtitle="Optional. It only affects which activities we think fit — Lotivity is not a dating app."
      canContinue
      backTo="/welcome/culture"
      nextTo="/welcome/interests"
      skipTo="/welcome/interests"
      onNext={() => updateDraft({ step: 7 })}
    >
      <BubbleGroup legend="Relationship status" multi={false}>
        {RELATIONSHIP_STATUSES.map((status) => (
          <Bubble
            key={status}
            role="radio"
            size="sm"
            label={status}
            selected={draft.relationshipStatus === status}
            onToggle={() =>
              updateDraft({
                relationshipStatus: draft.relationshipStatus === status ? undefined : status,
              })
            }
          />
        ))}
      </BubbleGroup>
    </StepFrame>
  );
}
