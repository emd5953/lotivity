import LotivityKit
import SwiftUI

/// FR-PROF-10. Optional, and explicitly not a dating signal (PRD §11).
struct RelationshipStep: View {
    @Binding var path: [OnboardingStep]
    @Environment(AppState.self) private var state

    var body: some View {
        StepFrame(
            title: "Relationship status",
            subtitle: "Optional. It only affects which activities we think fit — Lotivity is not a dating app.",
            onNext: {
                state.updateDraft { $0.step = 7 }
                path.append(.interests)
            },
            onBack: { path.removeLast() },
            onSkip: { path.append(.interests) }
        ) {
            BubbleGroup(legend: "Relationship status") {
                ForEach(relationshipStatuses, id: \.self) { status in
                    Bubble(
                        label: status,
                        isSelected: state.draft.relationshipStatus == status,
                        size: .small,
                        isExclusive: true
                    ) {
                        state.updateDraft {
                            $0.relationshipStatus = $0.relationshipStatus == status ? nil : status
                        }
                    }
                }
            }
        }
    }
}
