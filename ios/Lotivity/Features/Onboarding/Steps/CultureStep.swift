import LotivityKit
import SwiftUI

/// FR-PROF-9. One screen, two headings — faith and community are stored in
/// separate namespaces so they can be matched independently (PRD §9.1).
/// Fully optional: skipping costs nothing (PRD §9.2).
struct CultureStep: View {
    @Binding var path: [OnboardingStep]
    @Environment(AppState.self) private var state

    var body: some View {
        StepFrame(
            title: "Anything you'd want us to match on?",
            subtitle: "Optional. It helps us connect you with gatherings organized by and for your community.",
            onNext: {
                state.updateDraft { $0.step = 6 }
                path.append(.relationship)
            },
            onBack: { path.removeLast() },
            onSkip: { path.append(.relationship) }
        ) {
            VStack(alignment: .leading, spacing: 28) {
                BubbleGroup(legend: "Faith") {
                    ForEach(faithTags) { tag in bubble(tag) }
                }
                BubbleGroup(legend: "Community") {
                    ForEach(communityTags) { tag in bubble(tag) }
                }
                Text("We never verify or share these as facts about you. They only steer what we show you.")
                    .secondaryStyle()
            }
        }
    }

    private func bubble(_ tag: CultureTag) -> some View {
        Bubble(
            label: tag.label,
            isSelected: state.draft.cultureTags.contains(tag.id),
            size: .small
        ) {
            state.updateDraft { $0.cultureTags = toggleIn($0.cultureTags, tag.id) }
        }
    }
}
