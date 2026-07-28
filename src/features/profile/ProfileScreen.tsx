import { useNavigate } from 'react-router-dom';
import { useAppStore } from '@/app/store';
import { heritageLabel } from '@/data/reference/heritage';
import { cultureLabel, isFaith } from '@/data/reference/culture';
import { interestLabel } from '@/data/reference/interests';
import { INTEREST_BY_ID } from '@/data/reference/interests';
import { ACCOUNT_TYPES, generationLabel } from '@/lib/generation';
import { Button, Card, Pill, ScreenHeader } from '@/ui';

function TagRow({ label, values }: { label: string; values: string[] }) {
  if (values.length === 0) return null;
  return (
    <div>
      <p className="eyebrow">{label}</p>
      <div className="mt-2 flex flex-wrap gap-1.5">
        {values.map((v) => (
          <Pill key={v}>{v}</Pill>
        ))}
      </div>
    </div>
  );
}

export function ProfileScreen() {
  const { profile, resetDemo } = useAppStore();
  const navigate = useNavigate();

  // Guests reach this tab too — it's the pitch for signing up, not a dead end.
  if (!profile) {
    return (
      <>
        <ScreenHeader title="Profile" subtitle="Browsing as a guest" />
        <Card className="space-y-3">
          <p className="font-display text-[1.0625rem] font-semibold tracking-card text-cream">
            Nothing saved yet
          </p>
          <p className="text-sm leading-relaxed text-cream/45">
            Guests can browse everything nearby. Setting up a profile is what gets you matched
            on heritage, faith, and interests — and lets you attend, review, and connect.
          </p>
          <Button full onClick={() => navigate('/welcome')}>
            Set up your profile
          </Button>
        </Card>
      </>
    );
  }

  const accountType = ACCOUNT_TYPES.find((t) => t.id === profile.accountType);
  const faiths = profile.cultureTags.filter(isFaith).map(cultureLabel);
  const communities = profile.cultureTags.filter((t) => !isFaith(t)).map(cultureLabel);

  const handleReset = async () => {
    await resetDemo();
    navigate('/welcome', { replace: true });
  };

  return (
    <>
      <ScreenHeader title={profile.name} subtitle={accountType?.label} />

      <div className="space-y-4">
        <Card className="space-y-4">
          <div className="flex flex-wrap gap-1.5">
            <Pill tone="accent">{generationLabel(profile.generation)}</Pill>
            {profile.isGuest ? <Pill tone="info">Guest</Pill> : null}
            {profile.youthVerification ? (
              <Pill tone="warn">Guardian verification {profile.youthVerification.status}</Pill>
            ) : null}
          </div>

          {/* The privacy promise, stated where the user can see it (PRD §8). */}
          {/* The privacy promise is body copy, not fine print (DESIGN_SPEC §4.4). */}
          <p className="text-sm leading-relaxed text-cream/85">
            Your date of birth is never shown to anyone. Only your generation is.
          </p>
        </Card>

        <Card className="space-y-5">
          <TagRow label="Heritage" values={profile.heritage.map(heritageLabel)} />
          <TagRow label="Languages" values={profile.languages} />
          <TagRow label="Faith" values={faiths} />
          <TagRow label="Community" values={communities} />
          {profile.relationshipStatus ? (
            <TagRow label="Relationship" values={[profile.relationshipStatus]} />
          ) : null}
        </Card>

        <Card className="space-y-5">
          <TagRow label="Interests" values={profile.interests.map(interestLabel)} />
          <TagRow
            label="More specifically"
            values={profile.interestSubcategories.map((id) => {
              const [parent] = id.split('/');
              const interest = parent ? INTEREST_BY_ID.get(parent) : undefined;
              return interest?.subcategories.find((s) => s.id === id)?.label ?? id;
            })}
          />
        </Card>

        <Card className="space-y-3">
          <p className="eyebrow">Settings</p>
          <Button variant="secondary" full onClick={handleReset}>
            Reset demo
          </Button>
          <p className="text-sm leading-relaxed text-cream/45">
            Clears your profile and everything stored on this device, then starts onboarding over.
          </p>
        </Card>
      </div>
    </>
  );
}
