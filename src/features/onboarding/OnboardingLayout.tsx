import { useEffect } from 'react';
import { Outlet, useLocation, useNavigate } from 'react-router-dom';
import { Stepper } from '@/ui';
import { useAppStore } from '@/app/store';
import { STEP_PATHS } from './routes';

export function OnboardingLayout() {
  const { hydrated, hydrate, profile } = useAppStore();
  const location = useLocation();
  const navigate = useNavigate();

  useEffect(() => {
    if (!hydrated) void hydrate();
  }, [hydrated, hydrate]);

  // A completed profile has no business back in onboarding.
  useEffect(() => {
    if (hydrated && profile && location.pathname !== '/welcome/rendering') {
      navigate('/for-you', { replace: true });
    }
  }, [hydrated, profile, location.pathname, navigate]);

  const stepIndex = STEP_PATHS.indexOf(location.pathname);
  const showStepper = stepIndex > 0;

  if (!hydrated) {
    return (
      <div className="app-frame flex items-center justify-center">
        <p className="text-muted">Loading…</p>
      </div>
    );
  }

  return (
    <div className="app-frame flex min-h-dvh flex-col">
      {showStepper ? (
        <div className="screen-pad pt-6">
          <Stepper current={stepIndex - 1} total={STEP_PATHS.length - 2} />
        </div>
      ) : null}
      <div className="screen-pad flex flex-1 flex-col pb-8">
        <Outlet />
      </div>
    </div>
  );
}
