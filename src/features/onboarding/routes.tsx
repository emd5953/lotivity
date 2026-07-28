import type { RouteObject } from 'react-router-dom';
import { Entry } from './steps/Entry';
import { NameDob } from './steps/NameDob';
import { AccountTypeStep } from './steps/AccountTypeStep';
import { HeritageStep } from './steps/HeritageStep';
import { LanguagesStep } from './steps/LanguagesStep';
import { CultureStep } from './steps/CultureStep';
import { RelationshipStep } from './steps/RelationshipStep';
import { InterestsStep } from './steps/InterestsStep';
import { Rendering } from './steps/Rendering';

/**
 * Each step is its own route so browser back/forward work natively and a
 * refresh resumes in place (FR-PROF-14).
 */
export const STEP_PATHS = [
  '/welcome',
  '/welcome/name',
  '/welcome/account-type',
  '/welcome/heritage',
  '/welcome/languages',
  '/welcome/culture',
  '/welcome/relationship',
  '/welcome/interests',
  '/welcome/rendering',
];

export const onboardingRoutes: RouteObject[] = [
  { index: true, element: <Entry /> },
  { path: 'name', element: <NameDob /> },
  { path: 'account-type', element: <AccountTypeStep /> },
  { path: 'heritage', element: <HeritageStep /> },
  { path: 'languages', element: <LanguagesStep /> },
  { path: 'culture', element: <CultureStep /> },
  { path: 'relationship', element: <RelationshipStep /> },
  { path: 'interests', element: <InterestsStep /> },
  { path: 'rendering', element: <Rendering /> },
];
