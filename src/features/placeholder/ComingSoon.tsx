import { Link } from 'react-router-dom';
import { Card, Pill, ScreenHeader } from '@/ui';

/**
 * Deferred tabs stay in the navigation so the shell is complete and later
 * milestones drop in without restructuring. Named honestly rather than hidden.
 */
export function ComingSoon({
  title,
  body,
  milestone,
}: {
  title: string;
  body: string;
  milestone: string;
}) {
  return (
    <>
      <ScreenHeader title={title} trailing={<Pill>{milestone}</Pill>} />
      <Card className="space-y-3">
        <p className="text-sm leading-relaxed text-muted">{body}</p>
        <p className="text-sm text-muted">
          Not built yet — this MVP covers onboarding, For You, and the map.
        </p>
        <Link
          to="/for-you"
          className="inline-block text-sm font-medium text-brand underline underline-offset-4"
        >
          Back to For You →
        </Link>
      </Card>
    </>
  );
}
