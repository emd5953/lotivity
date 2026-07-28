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
        'inline-flex items-center gap-1.5 rounded-bubble border transition-colors',
        'disabled:opacity-40 disabled:cursor-not-allowed',
        size === 'sm' ? 'px-3 py-1.5 text-sm' : 'px-4 py-2.5 text-[0.95rem]',
        selected
          ? 'border-brand bg-brand text-white font-medium'
          : 'border-line bg-surface text-ink hover:border-brand/40 active:bg-brand-soft',
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
      <legend className={cx('text-sm font-medium text-muted mb-2', hideLegend && 'sr-only')}>
        {legend}
      </legend>
      {description ? <p className="text-sm text-muted mb-3">{description}</p> : null}
      <div className="flex flex-wrap gap-2">{children}</div>
    </fieldset>
  );
}
