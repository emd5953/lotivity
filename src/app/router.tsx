import { lazy, Suspense } from 'react';
import { createBrowserRouter, Navigate } from 'react-router-dom';
import { AppShell } from './AppShell';
import { ForYouScreen } from '@/features/foryou/ForYouScreen';
import { ProfileScreen } from '@/features/profile/ProfileScreen';
import { ComingSoon } from '@/features/placeholder/ComingSoon';
import { LandingScreen } from '@/features/landing/LandingScreen';
import { OnboardingLayout } from '@/features/onboarding/OnboardingLayout';
import { onboardingRoutes } from '@/features/onboarding/routes';

// MapLibre is the heaviest dependency in the app — never in the initial bundle
// (NFR-4, NFR-5).
const MapScreen = lazy(() =>
  import('@/features/map/MapScreen').then((m) => ({ default: m.MapScreen })),
);

const MapFallback = (
  <div className="eyebrow flex h-[60vh] items-center justify-center">Loading map…</div>
);

export const router = createBrowserRouter([
  // Marketing entry. `/` still opens straight into the feed — the landing
  // page is where people arrive from outside, not a wall in front of the app.
  { path: '/landing', element: <LandingScreen /> },
  {
    path: '/welcome',
    element: <OnboardingLayout />,
    children: onboardingRoutes,
  },
  {
    path: '/',
    element: <AppShell />,
    children: [
      { index: true, element: <Navigate to="/for-you" replace /> },
      { path: 'for-you', element: <ForYouScreen /> },
      {
        path: 'groups',
        element: (
          <ComingSoon
            title="Groups"
            body="Create a group, or put out a radius request and let the neighborhood organize around it. Requests that clear the upvote threshold get matched to a business and sponsored."
            milestone="M5"
          />
        ),
      },
      {
        path: 'social',
        element: (
          <ComingSoon
            title="Social"
            body="Seven-day recaps of where your network has been, voice-memo reviews, and connections earned through shared events."
            milestone="M6"
          />
        ),
      },
      {
        path: 'work',
        element: (
          <ComingSoon
            title="Work"
            body="Bridge people across companies for happy hours and paid activity bundles."
            milestone="M5"
          />
        ),
      },
      {
        path: 'map',
        element: (
          <Suspense fallback={MapFallback}>
            <MapScreen />
          </Suspense>
        ),
      },
      { path: 'profile', element: <ProfileScreen /> },
    ],
  },
  { path: '*', element: <Navigate to="/for-you" replace /> },
]);
