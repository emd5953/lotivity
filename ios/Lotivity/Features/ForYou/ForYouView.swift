import LotivityKit
import SwiftUI

struct HeritagePick {
    let heritageLabel: String
    let business: Business
    let weekday: String
    let positiveVotes: Int
}

struct ForYouView: View {
    let startOnboarding: () -> Void
    let openWork: () -> Void

    @Environment(AppState.self) private var state
    @State private var ranked: [ScoredEvent]?
    @State private var heritagePick: HeritagePick?

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ScreenHeader(title: title, subtitle: subtitle) {
                if !state.isGuest {
                    Chip(text: generationLabel(state.effectiveProfile.generation), tone: .accent)
                        .padding(.top, 6)
                }
            }

            if state.isGuest {
                guestNotice.padding(.bottom, 16)
            }

            if let ranked {
                if ranked.isEmpty {
                    EmptyStateCard(
                        title: "Nothing nearby yet",
                        message: "Widen your radius on the map to see what's happening further out."
                    )
                } else {
                    feed(ranked)
                }
            } else {
                Text("Finding things near you…")
                    .eyebrowStyle()
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 40)
            }

            Button("Looking for something with your team? →", action: openWork)
                .buttonStyle(LinkButtonStyle())
                .frame(maxWidth: .infinity)
                .padding(.top, 24)
        }
        .task(id: state.effectiveProfile) { await load() }
    }

    private var title: String {
        state.isGuest
            ? "Around you"
            : "Hey, \(state.effectiveProfile.name.split(separator: " ").first.map(String.init) ?? state.effectiveProfile.name)"
    }

    private var subtitle: String {
        state.isGuest
            ? "What's happening near you this week."
            : "What's worth leaving the house for this week."
    }

    private var guestNotice: some View {
        SurfaceCard {
            VStack(alignment: .leading, spacing: 8) {
                Text("You're browsing as a guest").cardTitleStyle()
                Text("This is sorted by what's closest. Tell us what you're into and it gets sorted by what's actually for you.")
                    .secondaryStyle()
                Button("Set up your profile →", action: startOnboarding)
                    .buttonStyle(LinkButtonStyle())
            }
        }
    }

    @ViewBuilder
    private func feed(_ scored: [ScoredEvent]) -> some View {
        LazyVStack(spacing: 12) {
            ForEach(scored.prefix(4)) { EventCardView(scored: $0) }

            if let heritagePick {
                HeritageNoticeView(pick: heritagePick)
            }

            ForEach(scored.dropFirst(4).prefix(14)) { EventCardView(scored: $0) }
        }
    }

    private func load() async {
        let profile = state.effectiveProfile
        let isGuest = state.isGuest
        let now = Date()

        let events = await Repo.upcomingEvents(now: now)
        let businesses = await Repo.businesses()

        // Network is fixture-side: the demo profile has no connections yet, so
        // borrow the seeded graph to keep the term meaningful.
        let networkIds = isGuest
            ? []
            : getWorld(now: now).connections.filter { $0.userId == "user:1" }.map(\.peerId)

        let scored = rankEvents(
            events,
            ScoreContext(
                user: ScoreContext.Subject(profile),
                now: now,
                networkIds: networkIds,
                // A guest has no network and no declared generation — scoring on
                // either would put a claim on the card that isn't true.
                suppressFactors: isGuest ? [.generationMatch, .networkAttendance] : [],
                heritageLabel: { heritageLabel($0) },
                cultureLabel: { cultureLabel($0) },
                interestLabel: { interestLabel($0) }
            )
        )

        // Prefer a heritage the user actually chose over the auto-filled home
        // country — "American spot" is a weaker hook than "Colombian spot".
        let heritageId = profile.heritage.first { $0 != homeHeritageID } ?? profile.heritage.first
        let heritage = heritageId.flatMap { heritageByID[$0] }
        let pick = businesses.first { $0.inNetwork && $0.mapFilter == .food }

        ranked = scored
        if let heritage, let pick {
            heritagePick = HeritagePick(
                heritageLabel: heritage.label,
                business: pick,
                weekday: Self.weekdayFormatter.string(from: now.addingTimeInterval(2 * 86_400)),
                positiveVotes: pick.positiveVotes7d
            )
        } else {
            heritagePick = nil
        }
    }

    private static let weekdayFormatter: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "en_US")
        f.dateFormat = "EEEE"
        return f
    }()
}
