import { useNavigate } from 'react-router-dom';
import { Button } from '@/ui';
import { useAppStore } from '@/app/store';

/**
 * FR-PROF-1. Google and Apple resolve instantly to a mock identity in v0 —
 * there is no real auth to fail against.
 */
export function Entry() {
  const navigate = useNavigate();
  const updateDraft = useAppStore((s) => s.updateDraft);

  const start = (authMethod: 'google' | 'apple') => {
    updateDraft({ authMethod, step: 1 });
    navigate('/welcome/name');
  };

  return (
    <div className="flex flex-1 flex-col justify-between gap-12 py-10">
      <div className="pt-12 text-center">
        <div
          aria-hidden="true"
          className="mx-auto mb-7 flex h-20 w-20 items-center justify-center rounded-[1.6rem] bg-accent text-3xl text-ink"
        >
          ◍
        </div>
        {/* The wordmark is a brand moment, so it keeps its capital. */}
        <h1 className="text-[2.375rem] font-semibold leading-none tracking-display text-cream">
          Lotivity
        </h1>
        <p className="eyebrow mt-3.5">Local Activities. At a Price Best for You.</p>
        <p className="mx-auto mt-8 max-w-[19rem] text-[0.95rem] leading-relaxed text-cream/45">
          Replacing artificial exchanges with real experiences. It&rsquo;s not revolutionary —
          it&rsquo;s real intelligence.
        </p>
      </div>

      <div className="space-y-3">
        <Button full onClick={() => start('google')}>
          Continue with Google
        </Button>
        <Button full variant="secondary" onClick={() => start('apple')}>
          Continue with Apple
        </Button>
        {/* Straight into the app — no profile, no wall (PRD §9.3). */}
        <Button full variant="ghost" onClick={() => navigate('/for-you')}>
          Look around first
        </Button>
        <p className="mx-auto max-w-[21rem] pt-1 text-center text-xs leading-relaxed text-cream/30">
          Guests can browse everything nearby. Attending, reviewing, and connecting need a profile.
        </p>
      </div>
    </div>
  );
}
