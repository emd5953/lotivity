import { useEffect, useRef, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { useAppStore } from '@/app/store';

const LINES = [
  'Reading your radius…',
  'Finding people who share your interests…',
  'Checking what your heritage communities are up to…',
  'Sorting what is actually worth leaving the house for…',
];

/** FR-PROF-13. Deliberately 2–4s — long enough to feel like work happened. */
export function Rendering() {
  const navigate = useNavigate();
  const completeOnboarding = useAppStore((s) => s.completeOnboarding);
  const [line, setLine] = useState(0);
  const started = useRef(false);

  useEffect(() => {
    // StrictMode double-invokes effects in dev; only run the real thing once.
    if (started.current) return;
    started.current = true;

    void completeOnboarding();

    const ticker = setInterval(() => {
      setLine((n) => Math.min(n + 1, LINES.length - 1));
    }, 700);

    const done = setTimeout(() => navigate('/for-you', { replace: true }), 3000);

    return () => {
      clearInterval(ticker);
      clearTimeout(done);
    };
  }, [completeOnboarding, navigate]);

  return (
    <div className="flex flex-1 flex-col items-center justify-center text-center">
      <div
        aria-hidden="true"
        className="mb-8 h-16 w-16 animate-spin rounded-full border-2 border-line border-t-brand"
      />
      <h1 className="text-xl font-semibold">Rendering your community…</h1>
      <p className="mt-3 h-5 text-[0.95rem] text-muted" aria-live="polite">
        {LINES[line]}
      </p>
    </div>
  );
}
