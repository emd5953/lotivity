import LotivityKit
import SwiftUI

/// FR-PROF-8.
struct LanguagesStep: View {
    @Binding var path: [OnboardingStep]
    @Environment(AppState.self) private var state

    var body: some View {
        StepFrame(
            title: "What do you speak?",
            subtitle: "Used to surface gatherings held in your languages.",
            onNext: {
                state.updateDraft { $0.step = 5 }
                path.append(.culture)
            },
            onBack: { path.removeLast() }
        ) {
            BubbleGroup(legend: "Languages spoken") {
                ForEach(languages, id: \.self) { language in
                    Bubble(
                        label: language,
                        isSelected: state.draft.languages.contains(language),
                        size: .small
                    ) {
                        state.updateDraft { $0.languages = toggleIn($0.languages, language) }
                    }
                }
            }
        }
    }
}
