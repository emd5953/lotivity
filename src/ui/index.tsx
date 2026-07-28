import type { ButtonHTMLAttributes, ReactNode } from 'react';

const cx = (...parts: (string | false | undefined)[]) => parts.filter(Boolean).join(' ');

export { Bubble, BubbleGroup } from './Bubble';

interface ButtonProps extends ButtonHTMLAttributes<HTMLButtonElement> {
  variant?: 'primary' | 'secondary' | 'ghost';
  full?: boolean;
}

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
        'inline-flex items-center justify-center gap-2 rounded-bubble px-6 py-3.5 font-medium',
        'transition-colors disabled:opacity-40 disabled:cursor-not-allowed',
        full && 'w-full',
        variant === 'primary' && 'bg-brand text-white hover:bg-brand/90',
        variant === 'secondary' && 'border border-line bg-surface text-ink hover:border-brand/40',
        variant === 'ghost' && 'text-muted hover:text-ink',
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
  return (
    <Tag className={cx('rounded-card border border-line bg-surface p-4', className)}>
      {children}
    </Tag>
  );
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
          className={cx(
            'h-1 flex-1 rounded-full transition-colors',
            i <= current ? 'bg-brand' : 'bg-line',
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
      <div
        className="absolute inset-0 bg-ink/30"
        onClick={onClose}
        aria-hidden="true"
      />
      <div
        role="dialog"
        aria-modal="true"
        aria-label={title}
        className="relative w-full max-w-app rounded-t-sheet bg-surface p-5 pb-8 shadow-xl"
      >
        <div className="mx-auto mb-4 h-1 w-10 rounded-full bg-line" />
        {children}
        <Button variant="secondary" full className="mt-4" onClick={onClose}>
          Close
        </Button>
      </div>
    </div>
  );
}

export function Pill({ children, tone = 'neutral' }: { children: ReactNode; tone?: 'neutral' | 'brand' | 'accent' | 'warn' }) {
  return (
    <span
      className={cx(
        'inline-flex items-center rounded-bubble px-2.5 py-1 text-xs font-medium',
        tone === 'neutral' && 'bg-canvas text-muted',
        tone === 'brand' && 'bg-brand-soft text-brand',
        tone === 'accent' && 'bg-accent/15 text-accent',
        tone === 'warn' && 'bg-warn/10 text-warn',
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
    <header className="flex items-start justify-between gap-3 pb-4 pt-6">
      <div>
        <h1 className="text-2xl font-semibold tracking-tight">{title}</h1>
        {subtitle ? <p className="mt-1 text-sm text-muted">{subtitle}</p> : null}
      </div>
      {trailing}
    </header>
  );
}

export function EmptyState({ title, body }: { title: string; body: string }) {
  return (
    <Card className="text-center">
      <p className="font-medium">{title}</p>
      <p className="mt-1 text-sm text-muted">{body}</p>
    </Card>
  );
}
