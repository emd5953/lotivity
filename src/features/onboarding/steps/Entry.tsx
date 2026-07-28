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

  const start = (authMethod: 'google' | 'apple' | 'guest') => {
    updateDraft({ authMethod, step: 1 });
    navigate('/welcome/name');
  };

  return (
    <div className="flex flex-1 flex-col justify-between py-10">
      <div className="pt-12 text-center">
        <div
          aria-hidden="true"
          className="mx-auto mb-7 flex h-20 w-20 items-center justify-center rounded-[1.6rem] bg-brand text-3xl text-white"
        >
          ◍
        </div>
        <h1 className="text-3xl font-semibold tracking-tight">Lotivity</h1>
        <p className="mt-2 text-muted">Local Activities. At a Price Best for You.</p>
        <p className="mx-auto mt-8 max-w-[19rem] text-[0.95rem] leading-relaxed text-muted">
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
        <Button full variant="ghost" onClick={() => start('guest')}>
          Look around as a guest
        </Button>
        <p className="pt-1 text-center text-xs text-muted">
          Guests can browse everything nearby. Attending, reviewing, and connecting need a profile.
        </p>
      </div>
    </div>
  );
}
