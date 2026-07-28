import type { ReactNode } from 'react';

const cx = (...parts: (string | false | undefined)[]) => parts.filter(Boolean).join(' ');

interface BubbleProps {
  label: ReactNode;
  selected: boolean;
  onToggle: () => void;
  /** 'radio' for single-select groups, 'checkbox' for multi-select. */
  role?: 'checkbox' | 'radio';
  disabled?: boolean;
  size?: 'sm' | 'md';
  hint?: string;
}

/**
 * The signature interaction of the product. Uses real ARIA states rather than
 * styled buttons so screen readers announce selection correctly (NFR-7).
 *
 * Selection is an olive INSET ring plus olive text, not an olive fill
 * (DESIGN_SPEC §1.4). A filter row that defaults to all-on would otherwise
 * paint a whole band solid olive, and olive that covers everything has
 * stopped meaning "alive". Nothing reflows between states either way.
 */
export function Bubble({
  label,
  selected,
  onToggle,
  role = 'checkbox',
  disabled = false,
  size = 'md',
  hint,
}: BubbleProps) {
  return (
    <button
      type="button"
      role={role}
      aria-checked={selected}
      aria-describedby={hint}
      disabled={disabled}
      onClick={onToggle}
      className={cx(
        'inline-flex items-center gap-1.5 rounded-bubble ring-1 ring-inset',
        'transition-colors duration-150 disabled:cursor-not-allowed disabled:opacity-40',
        size === 'sm' ? 'px-3 py-1.5 text-sm' : 'px-4 py-2.5 text-[0.95rem]',
        selected
          ? 'bg-accent/10 font-medium text-accent ring-accent'
          : 'bg-raised text-cream/85 ring-cream/12 hover:bg-raised2 hover:text-cream',
      )}
    >
      {label}
    </button>
  );
}

interface BubbleGroupProps {
  legend: string;
  /** Visually hides the legend but keeps it for assistive tech. */
  hideLegend?: boolean;
  multi?: boolean;
  children: ReactNode;
  description?: string;
}

export function BubbleGroup({
  legend,
  hideLegend = false,
  multi = true,
  children,
  description,
}: BubbleGroupProps) {
  return (
    <fieldset role={multi ? 'group' : 'radiogroup'} aria-label={legend}>
      <legend className={cx('eyebrow mb-2.5', hideLegend && 'sr-only')}>{legend}</legend>
      {description ? <p className="mb-3 text-sm text-cream/45">{description}</p> : null}
      <div className="flex flex-wrap gap-2">{children}</div>
    </fieldset>
  );
}
