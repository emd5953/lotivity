import { useAppStore } from '@/app/store';
import { generationFromDob, generationLabel } from '@/lib/generation';
import { Pill } from '@/ui';
import { StepFrame } from '../StepFrame';

/** FR-PROF-2, FR-PROF-3. DOB is collected to derive generation, never shown. */
export function NameDob() {
  const { draft, updateDraft } = useAppStore();
  const hasDob = draft.dob.length === 10;
  const generation = hasDob ? generationFromDob(draft.dob) : null;

  return (
    <StepFrame
      title="Let's start with you"
      subtitle="Your name and generation are visible to others. Your date of birth is not."
      canContinue={draft.name.trim().length > 1 && hasDob}
      backTo="/welcome"
      nextTo="/welcome/account-type"
      onNext={() => updateDraft({ step: 2 })}
      blockedHint="Add your name and date of birth to continue."
    >
      <div className="space-y-6">
        <div>
          <label htmlFor="name" className="mb-2 block text-sm font-medium text-muted">
            Name
          </label>
          <input
            id="name"
            type="text"
            autoComplete="name"
            value={draft.name}
            onChange={(e) => updateDraft({ name: e.target.value })}
            placeholder="Your name"
            className="w-full rounded-card border border-line bg-surface px-4 py-3.5 text-[1.05rem] placeholder:text-muted/60"
          />
        </div>

        <div>
          <label htmlFor="dob" className="mb-2 block text-sm font-medium text-muted">
            Date of birth
          </label>
          <input
            id="dob"
            type="date"
            value={draft.dob}
            max="2020-12-31"
            min="1920-01-01"
            onChange={(e) => updateDraft({ dob: e.target.value })}
            aria-describedby="dob-help"
            className="w-full rounded-card border border-line bg-surface px-4 py-3.5 text-[1.05rem]"
          />
          <p id="dob-help" className="mt-2 text-sm text-muted">
            Never shown to anyone. We use it to work out your generation, which is.
          </p>
        </div>

        {generation ? (
          <div className="rounded-card bg-brand-soft p-4" aria-live="polite">
            <p className="text-sm text-muted">Others will see</p>
            <p className="mt-2 flex items-center gap-2">
              <span className="font-medium">{draft.name.trim() || 'Your name'}</span>
              <Pill tone="brand">{generationLabel(generation)}</Pill>
            </p>
          </div>
        ) : null}
      </div>
    </StepFrame>
  );
}
