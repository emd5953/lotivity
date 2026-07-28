import type { ButtonHTMLAttributes, ReactNode } from 'react';

const cx = (...parts: (string | false | undefined)[]) => parts.filter(Boolean).join(' ');

export { Bubble, BubbleGroup } from './Bubble';

interface ButtonProps extends ButtonHTMLAttributes<HTMLButtonElement> {
  variant?: 'primary' | 'secondary' | 'ghost';
  full?: boolean;
}

/**
 * The pill system (DESIGN_SPEC §5). Ghost pills ring on the inside, so a
 * hover never changes the pill's measured size. At most one `primary` — the
 * cream fill — per screen; it is the payoff.
 */
export function Button({
  variant = 'primary',
  full = false,
  className,
  children,
  ...rest
}: ButtonProps) {
  return (
    <button
      className={cx(
        'pill px-6 py-3.5 text-[0.95rem]',
        full && 'w-full',
        variant === 'primary' && 'pill-cream',
        variant === 'secondary' && 'pill-ghost',
        variant === 'ghost' && 'pill-quiet',
        className,
      )}
      {...rest}
    >
      {children}
    </button>
  );
}

export function Card({
  children,
  className,
  as: Tag = 'div',
}: {
  children: ReactNode;
  className?: string;
  as?: 'div' | 'article' | 'li';
}) {
  return <Tag className={cx('surface-card p-4', className)}>{children}</Tag>;
}

export function Stepper({ current, total }: { current: number; total: number }) {
  return (
    <div
      className="flex gap-1.5"
      role="progressbar"
      aria-valuenow={current + 1}
      aria-valuemin={1}
      aria-valuemax={total}
      aria-label={`Step ${current + 1} of ${total}`}
    >
      {Array.from({ length: total }, (_, i) => (
        <span
          key={i}
          // Progress is the one thing on this screen that is alive.
          className={cx(
            'h-0.5 flex-1 rounded-full transition-colors duration-200',
            i <= current ? 'bg-accent' : 'bg-cream/12',
          )}
        />
      ))}
    </div>
  );
}

export function Sheet({
  open,
  onClose,
  title,
  children,
}: {
  open: boolean;
  onClose: () => void;
  title: string;
  children: ReactNode;
}) {
  if (!open) return null;
  return (
    <div className="fixed inset-0 z-40 flex items-end justify-center">
      <div className="absolute inset-0 bg-bg/70 backdrop-blur-sm" onClick={onClose} aria-hidden="true" />
      <div
        role="dialog"
        aria-modal="true"
        aria-label={title}
        className="relative w-full max-w-app rounded-t-sheet bg-soft p-5 pb-8 ring-1 ring-inset ring-cream/12"
      >
        <div className="mx-auto mb-4 h-1 w-10 rounded-full bg-cream/20" />
        {children}
        <Button variant="secondary" full className="mt-4" onClick={onClose}>
          Close
        </Button>
      </div>
    </div>
  );
}

export function Pill({
  children,
  tone = 'neutral',
}: {
  children: ReactNode;
  tone?: 'neutral' | 'accent' | 'info' | 'warn';
}) {
  return (
    <span
      className={cx(
        'chip-label inline-flex items-center rounded-bubble px-2.5 py-1',
        tone === 'neutral' && 'bg-cream/6 text-cream/60',
        // Olive is aliveness — reserved for what the user is or has chosen.
        tone === 'accent' && 'bg-accent/15 text-accent',
        // A sponsor is informational, not the user's own aliveness.
        tone === 'info' && 'bg-teal/15 text-teal',
        tone === 'warn' && 'bg-error/15 text-error',
      )}
    >
      {children}
    </span>
  );
}

export function ScreenHeader({
  title,
  subtitle,
  trailing,
}: {
  title: string;
  subtitle?: string;
  trailing?: ReactNode;
}) {
  return (
    <header className="flex items-start justify-between gap-3 pb-5 pt-7">
      <div>
        <h1 className="text-[1.875rem] font-semibold leading-none tracking-display text-cream">
          {title}
        </h1>
        {subtitle ? <p className="mt-2.5 text-sm text-cream/45">{subtitle}</p> : null}
      </div>
      {trailing}
    </header>
  );
}

export function EmptyState({ title, body }: { title: string; body: string }) {
  return (
    <Card className="text-center">
      <p className="font-display text-[1.0625rem] font-semibold tracking-card text-cream">
        {title}
      </p>
      <p className="mt-1.5 text-sm leading-relaxed text-cream/45">{body}</p>
    </Card>
  );
}
