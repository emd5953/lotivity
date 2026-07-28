import type { ReactNode } from 'react';
import { useNavigate } from 'react-router-dom';
import { Button } from '@/ui';

interface StepFrameProps {
  title: string;
  subtitle?: string;
  children: ReactNode;
  /** Falsy blocks advancing — used by the exactly-6 interests gate. */
  canContinue: boolean;
  nextTo: string;
  backTo?: string;
  onNext?: () => void;
  nextLabel?: string;
  /** Optional skip target for genuinely optional steps (FR-PROF-9, 10). */
  skipTo?: string;
  blockedHint?: string;
}

export function StepFrame({
  title,
  subtitle,
  children,
  canContinue,
  nextTo,
  backTo,
  onNext,
  nextLabel = 'Next',
  skipTo,
  blockedHint,
}: StepFrameProps) {
  const navigate = useNavigate();

  const go = () => {
    onNext?.();
    navigate(nextTo);
  };

  return (
    <div className="flex flex-1 flex-col">
      <div className="pt-8">
        <h1 className="text-[1.875rem] font-semibold leading-[1.05] tracking-display text-cream">
          {title}
        </h1>
        {subtitle ? <p className="mt-3 text-[0.95rem] text-cream/45">{subtitle}</p> : null}
      </div>

      <div className="flex-1 py-7">{children}</div>

      <div className="sticky bottom-0 space-y-3 bg-bg pb-2 pt-3">
        {blockedHint && !canContinue ? (
          <p className="eyebrow text-center" aria-live="polite">
            {blockedHint}
          </p>
        ) : null}
        <Button full onClick={go} disabled={!canContinue}>
          {nextLabel}
        </Button>
        <div className="flex items-center justify-between">
          {backTo ? (
            <Button variant="ghost" onClick={() => navigate(backTo)}>
              Back
            </Button>
          ) : (
            <span />
          )}
          {skipTo ? (
            <Button variant="ghost" onClick={() => navigate(skipTo)}>
              Skip
            </Button>
          ) : (
            <span />
          )}
        </div>
      </div>
    </div>
  );
}
