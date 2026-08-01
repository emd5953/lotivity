import SwiftUI

enum Tab: String, CaseIterable, Identifiable {
    case forYou, groups, social, work, map, profile

    var id: String { rawValue }

    /// Work has no tab of its own — it is reached from the feed, the same as the
    /// web app's `/work` link.
    static let barTabs: [Tab] = [.forYou, .groups, .social, .map, .profile]

    var label: String {
        switch self {
        case .forYou: "For You"
        case .groups: "Groups"
        case .social: "Social"
        case .work: "Work"
        case .map: "Map"
        case .profile: "Profile"
        }
    }

    /// SF Symbols rather than literal glyphs — several of the web app's
    /// characters (☺, ❋) resolve to color emoji on iOS, and a colored icon in a
    /// bar that encodes state with olive would be lying.
    var glyph: String {
        switch self {
        case .forYou: "sparkle"
        case .groups: "circle.circle"
        case .social: "asterisk"
        case .work: "briefcase"
        case .map: "scope"
        case .profile: "person"
        }
    }
}

/// No login wall. Without a profile you browse in guest mode (PRD §9.3) —
/// requiring signup to see whether anything is happening nearby is the fastest
/// way to lose someone in a city we just launched in.
struct RootView: View {
    @Environment(AppState.self) private var state
    @State private var tab: Tab = .forYou
    @State private var showOnboarding = false

    var body: some View {
        AppBackground {
            VStack(spacing: 0) {
                ScrollView {
                    screen
                        .padding(.horizontal, Metrics.screenPad)
                        .padding(.bottom, 24)
                }
                .scrollIndicators(.hidden)

                TabBar(selection: $tab)
            }
        }
        .fullScreenCover(isPresented: $showOnboarding) {
            OnboardingFlow { tab = .forYou }
                .environment(state)
        }
    }

    @ViewBuilder
    private var screen: some View {
        switch tab {
        case .forYou:
            ForYouView(startOnboarding: { showOnboarding = true }, openWork: { tab = .work })
        case .groups:
            ComingSoonView(
                title: "Groups",
                message: "Create a group, or put out a radius request and let the neighborhood organize around it. Requests that clear the upvote threshold get matched to a business and sponsored.",
                milestone: "M5",
                back: { tab = .forYou }
            )
        case .social:
            ComingSoonView(
                title: "Social",
                message: "Seven-day recaps of where your network has been, voice-memo reviews, and connections earned through shared events.",
                milestone: "M6",
                back: { tab = .forYou }
            )
        case .work:
            ComingSoonView(
                title: "Work",
                message: "Bridge people across companies for happy hours and paid activity bundles.",
                milestone: "M5",
                back: { tab = .forYou }
            )
        case .map:
            MapScreenView()
        case .profile:
            ProfileView(startOnboarding: { showOnboarding = true })
        }
    }
}

/// A fixed bar on `soft` with one hairline above it, respecting the home
/// indicator inset (DESIGN_SPEC §3.1). Built by hand rather than with `TabView`
/// so the labels can stay mono, lowercase, and olive-when-live.
private struct TabBar: View {
    @Binding var selection: Tab

    var body: some View {
        HStack(spacing: 0) {
            ForEach(Tab.barTabs) { tab in
                Button {
                    selection = tab
                } label: {
                    VStack(spacing: 4) {
                        Image(systemName: tab.glyph)
                            .font(.system(size: 16))
                            .accessibilityHidden(true)
                        Text(tab.label)
                            // The tab you are on is the live one, so it is olive.
                            .chipLabelStyle(selection == tab ? .olive : Ramp.muted)
                    }
                    .foregroundStyle(selection == tab ? Color.olive : Ramp.muted)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityAddTraits(selection == tab ? [.isSelected] : [])
            }
        }
        .animation(Motion.selection, value: selection)
        .frame(maxWidth: Metrics.maxWidth)
        .frame(maxWidth: .infinity)
        .background(alignment: .top) {
            Rectangle().fill(Ramp.hairline).frame(height: 1)
        }
        .background(Color.lotSoft.opacity(0.97))
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Primary")
    }
}
