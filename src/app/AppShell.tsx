import { useEffect } from 'react';
import { NavLink, Outlet } from 'react-router-dom';
import { useAppStore } from './store';

const TABS = [
  { to: '/for-you', label: 'For You', icon: '✦' },
  { to: '/groups', label: 'Groups', icon: '◎' },
  { to: '/social', label: 'Social', icon: '❋' },
  { to: '/map', label: 'Map', icon: '⌖' },
  { to: '/profile', label: 'Profile', icon: '☺' },
];

export function AppShell() {
  const { hydrated, hydrate } = useAppStore();
  useEffect(() => {
    if (!hydrated) void hydrate();
  }, [hydrated, hydrate]);

  // No login wall. Without a profile you browse in guest mode (PRD §9.3) —
  // requiring signup to see whether anything is happening nearby is the
  // fastest way to lose someone in a city we just launched in.
  if (!hydrated) {
    return (
      <div className="app-frame flex items-center justify-center">
        <p className="eyebrow">Loading…</p>
      </div>
    );
  }

  return (
    <div className="app-frame pb-tab-bar">
      <main className="screen-pad pb-6">
        <Outlet />
      </main>

      <nav
        aria-label="Primary"
        className="fixed bottom-0 left-1/2 z-30 w-full max-w-app -translate-x-1/2 bg-soft/95 pb-safe-b shadow-[inset_0_1px_0_0_rgb(var(--c-cream)/0.09)] backdrop-blur"
      >
        <ul className="flex">
          {TABS.map((tab) => (
            <li key={tab.to} className="flex-1">
              <NavLink
                to={tab.to}
                className={({ isActive }) =>
                  [
                    'chip-label flex flex-col items-center gap-1 py-2.5 transition-colors duration-150',
                    // The tab you are on is the live one, so it is the olive one.
                    isActive ? 'text-accent' : 'text-cream/45 hover:text-cream/60',
                  ].join(' ')
                }
              >
                <span aria-hidden="true" className="text-lg leading-none">
                  {tab.icon}
                </span>
                {tab.label}
              </NavLink>
            </li>
          ))}
        </ul>
      </nav>
    </div>
  );
}
