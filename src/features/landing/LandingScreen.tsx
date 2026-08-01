import { Link } from 'react-router-dom';
import { Card, Pill } from '@/ui';

/**
 * The marketing entry. Same dark room as the app — a landing page that does
 * not look like the product is a promise the product has to pay back.
 *
 * Exactly one cream payoff on this screen (DESIGN_SPEC §5): "Set up your
 * radius". Everything else is ghost or quiet.
 */

const STEPS = [
  {
    n: '01',
    title: 'Tell us who you are',
    body: 'Generation, heritage, faith, interests, and how far you are willing to travel. Six questions, one per screen.',
  },
  {
    n: '02',
    title: 'See what is actually near',
    body: 'Real gatherings inside your radius, ranked by how well they match — never by who paid the most.',
  },
  {
    n: '03',
    title: 'Go, then say what it was like',
    body: 'Honest reviews earn discounts. Businesses in the network sponsor the gatherings that share their values.',
  },
];

const CATEGORIES = [
  { label: 'sports', dot: 'bg-moss' },
  { label: 'social gatherings', dot: 'bg-sand' },
  { label: 'faith & culture', dot: 'bg-plum' },
  { label: 'volunteer work', dot: 'bg-slate' },
  { label: 'paid events', dot: 'bg-clay' },
  { label: 'work meetups', dot: 'bg-teal' },
];

export function LandingScreen() {
  return (
    <div className="app-frame">
      <main className="screen-pad pb-16">
        <header className="flex items-center justify-between pt-7">
          {/* The wordmark is the one place "Lotivity" stays capitalized
              (DESIGN_SPEC §2.3). */}
          <span className="font-display text-[1.0625rem] font-semibold tracking-card text-cream">
            Lotivity
          </span>
          <Link to="/for-you" className="pill pill-quiet chip-label px-3 py-2">
            Browse as guest
          </Link>
        </header>

        <section className="animate-enter pt-14">
          <p className="eyebrow">local activities · at a price best for you</p>
          <h1 className="mt-3 text-[1.875rem] font-semibold leading-[1.08] tracking-display text-cream">
            Something is happening within a mile of you.
          </h1>
          <p className="mt-4 text-[0.9375rem] leading-relaxed text-cream/85">
            Lotivity matches you to real gatherings in your radius by generation, heritage, faith,
            and interest — and every card tells you why it is there.
          </p>

          <div className="mt-7 flex items-center gap-4">
            <Link to="/welcome" className="pill pill-cream px-6 py-3.5 text-[0.95rem]">
              Set up your radius
            </Link>
            <Link to="/for-you" className="pill pill-quiet text-[0.95rem]">
              Skip it →
            </Link>
          </div>

          <p className="mt-4 text-sm text-cream/45">
            <span className="font-mono tabular-nums">6</span> questions. No account required to
            look around.
          </p>
        </section>

        {/* The feed card is the product. Show it rather than describe it. */}
        <section className="pt-16">
          <p className="eyebrow">a card from your feed</p>
          <Card className="mt-3 space-y-3">
            <div className="flex items-start justify-between gap-3">
              <div>
                <p className="eyebrow">Thu, Aug 6 · 6:30 PM</p>
                <h2 className="mt-1.5 text-[1.0625rem] font-semibold leading-snug tracking-card text-cream">
                  Sunset run · Prospect Park loop
                </h2>
                <p className="mt-1 text-sm text-cream/45">
                  Park Slope · <span className="font-mono tabular-nums">0.4 mi</span>
                </p>
              </div>
            </div>
            <div className="flex flex-wrap gap-1.5">
              <Pill tone="accent">Free</Pill>
              <Pill>14 going</Pill>
            </div>
            <p className="-mx-4 -mb-4 rounded-b-card bg-cream/2.2 px-4 py-3 text-sm text-cream/45">
              Matches your running interest · 11 people in your generation are going
            </p>
          </Card>
          <p className="mt-3 text-sm leading-relaxed text-cream/85">
            That last line is the whole point. A card that cannot explain itself does not ship.
          </p>
        </section>

        <section className="pt-16">
          <p className="eyebrow">how it works</p>
          <ol className="mt-3 overflow-hidden rounded-card">
            {STEPS.map((step, i) => (
              // Structure by luminance step, not by rules between rows
              // (DESIGN_SPEC §1.4).
              <li
                key={step.n}
                className={`flex gap-4 px-4 py-4 ${i % 2 === 0 ? 'bg-cream/3.5' : 'bg-cream/2.2'}`}
              >
                <span className="font-mono text-[0.6875rem] tabular-nums tracking-eyebrow text-cream/30">
                  {step.n}
                </span>
                <div>
                  <h3 className="text-[0.9375rem] font-semibold tracking-card text-cream">
                    {step.title}
                  </h3>
                  <p className="mt-1 text-sm leading-relaxed text-cream/45">{step.body}</p>
                </div>
              </li>
            ))}
          </ol>
        </section>

        <section className="pt-16">
          <p className="eyebrow">what is on the map</p>
          <ul className="mt-3 flex flex-wrap gap-2">
            {CATEGORIES.map((cat) => (
              <li
                key={cat.label}
                className="chip-label inline-flex items-center gap-2 rounded-bubble bg-raised px-3 py-1.5 text-cream/60 ring-1 ring-inset ring-cream/12"
              >
                <span aria-hidden="true" className={`h-2 w-2 rounded-full ${cat.dot}`} />
                {cat.label}
              </li>
            ))}
          </ul>
        </section>

        <section className="pt-16">
          <p className="eyebrow">what we do with what you tell us</p>
          <p className="mt-3 text-[0.9375rem] leading-relaxed text-cream/85">
            Your date of birth is never shown to anyone. Heritage and faith are used to find you
            gatherings and local sponsorship — not to sell you to advertisers. Reach on Lotivity is
            earned by relevance, not bid.
          </p>
        </section>

        <footer className="mt-16 border-t border-cream/9 pt-6">
          <p className="eyebrow">
            Lotivity · replacing artificial exchanges with real experiences
          </p>
          <Link
            to="/welcome"
            className="mt-3 inline-block text-sm font-medium text-accent underline underline-offset-4 hover:text-accent-hi"
          >
            Set up your radius →
          </Link>
        </footer>
      </main>
    </div>
  );
}
