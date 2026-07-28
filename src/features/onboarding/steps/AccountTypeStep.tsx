import { useAppStore } from '@/app/store';
import { ACCOUNT_TYPES, suggestAccountType } from '@/lib/generation';
import { Bubble, BubbleGroup } from '@/ui';
import { StepFrame } from '../StepFrame';

/** FR-PROF-4, 5, 6. */
export function AccountTypeStep() {
  const { draft, updateDraft } = useAppStore();
  const suggested = draft.dob ? suggestAccountType(draft.dob) : null;
  const selected = draft.accountType ?? suggested ?? undefined;
  const active = ACCOUNT_TYPES.find((t) => t.id === selected);

  return (
    <StepFrame
      title="Which fits your life right now?"
      canContinue={Boolean(selected)}
      backTo="/welcome/name"
      nextTo="/welcome/heritage"
      onNext={() => updateDraft({ accountType: selected, step: 3 })}
    >
      <div className="space-y-5">
        <BubbleGroup legend="Account type" hideLegend multi={false}>
          {ACCOUNT_TYPES.map((type) => (
            <Bubble
              key={type.id}
              role="radio"
              label={type.label}
              selected={selected === type.id}
              onToggle={() => updateDraft({ accountType: type.id })}
            />
          ))}
        </BubbleGroup>

        {active ? (
          <p className="text-[0.95rem] leading-relaxed text-cream/60" aria-live="polite">
            {active.blurb}
          </p>
        ) : null}

        {/* FR-PROF-5 — the incentive is stated plainly rather than buried. */}
        <div className="surface-card p-4">
          <p className="text-sm leading-relaxed text-cream/45">
            Community promotions are matched to these categories. Picking the one that actually
            reflects your life is what gets you the discounts and gatherings meant for you.
          </p>
        </div>

        {selected === 'youth' ? (
          <div className="rounded-card bg-accent/10 p-4 ring-1 ring-inset ring-accent/30">
            <p className="font-display font-semibold tracking-card text-cream">
              Youth accounts need a verified adult
            </p>
            <p className="mt-1.5 text-sm leading-relaxed text-cream/60">
              Any event you host or attend needs a community-appointed host or parent who has
              verified their ID. We&rsquo;ll walk you through it after setup.
            </p>
          </div>
        ) : null}
      </div>
    </StepFrame>
  );
}
