/** @type {import('tailwindcss').Config} */
export default {
  content: ['./index.html', './src/**/*.{ts,tsx}'],
  theme: {
    extend: {
      colors: {
        // Tokens resolve to CSS custom properties (src/index.css) so the
        // palette can shift without touching component classes.
        bg: 'rgb(var(--c-bg) / <alpha-value>)',
        soft: 'rgb(var(--c-soft) / <alpha-value>)',
        raised: 'rgb(var(--c-raised) / <alpha-value>)',
        raised2: 'rgb(var(--c-raised2) / <alpha-value>)',
        cream: 'rgb(var(--c-cream) / <alpha-value>)',
        ink: 'rgb(var(--c-ink) / <alpha-value>)',
        accent: 'rgb(var(--c-accent) / <alpha-value>)',
        'accent-hi': 'rgb(var(--c-accent-hi) / <alpha-value>)',
        'accent-lo': 'rgb(var(--c-accent-lo) / <alpha-value>)',
        teal: 'rgb(var(--c-teal) / <alpha-value>)',
        error: 'rgb(var(--c-error) / <alpha-value>)',
        success: 'rgb(var(--c-success) / <alpha-value>)',
        // Categorical encoding only — map pins, club categories. No orange.
        sand: 'rgb(var(--c-sand) / <alpha-value>)',
        plum: 'rgb(var(--c-plum) / <alpha-value>)',
        slate: 'rgb(var(--c-slate) / <alpha-value>)',
        moss: 'rgb(var(--c-moss) / <alpha-value>)',
        clay: 'rgb(var(--c-clay) / <alpha-value>)',
      },
      fontFamily: {
        // Display is tight and packed; body is plain; chrome is mono.
        display: ['"Inter Tight"', 'Inter', 'system-ui', 'sans-serif'],
        sans: ['Inter', 'system-ui', '-apple-system', 'sans-serif'],
        mono: ['"JetBrains Mono"', 'ui-monospace', 'SFMono-Regular', 'Menlo', 'monospace'],
      },
      // The luminance ramp of DESIGN_SPEC §1.3–1.4, so `ring-cream/12` and
      // `bg-cream/3.5` are first-class instead of arbitrary values.
      opacity: {
        2.2: '0.022',
        3.5: '0.035',
        6: '0.06',
        7: '0.07',
        9: '0.09',
        12: '0.12',
        22: '0.22',
        45: '0.45',
        85: '0.85',
      },
      letterSpacing: {
        display: '-0.04em',
        title: '-0.03em',
        card: '-0.02em',
        eyebrow: '0.08em',
        chip: '0.06em',
      },
      boxShadow: {
        // Ghost pills ring on the INSIDE so their size never shifts.
        ghost: 'inset 0 0 0 1px rgb(var(--c-cream) / 0.22)',
        'ghost-hi': 'inset 0 0 0 1px rgb(var(--c-cream) / 0.45)',
      },
      // Card entrance, 0.25s ease-out (DESIGN_SPEC §3.3). Not a loop —
      // and prefers-reduced-motion flattens it globally in src/index.css.
      keyframes: {
        enter: {
          from: { opacity: '0', transform: 'translateY(6px)' },
          to: { opacity: '1', transform: 'none' },
        },
      },
      animation: {
        enter: 'enter 0.25s ease-out both',
      },
      borderRadius: {
        bubble: '999px',
        card: '1rem',
        sheet: '1.5rem',
      },
      maxWidth: {
        app: '30rem',
      },
      spacing: {
        'tab-bar': '4.25rem',
        'safe-b': 'env(safe-area-inset-bottom)',
      },
    },
  },
  plugins: [],
};
