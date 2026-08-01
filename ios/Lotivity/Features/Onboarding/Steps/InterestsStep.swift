import LotivityKit
import SwiftUI

/// FR-PROF-11 (exactly 6 to proceed) and FR-PROF-12 (subcategories, optional).
struct InterestsStep: View {
    @Binding var path: [OnboardingStep]
    @Environment(AppState.self) private var state

    private var chosen: [ID] { state.draft.interests }
    private var atLimit: Bool { chosen.count >= requiredInterestCount }
    private var remaining: Int { requiredInterestCount - chosen.count }

    var body: some View {
        StepFrame(
            title: "Pick 6 things you're into",
            subtitle: "You can add more later. These do the heavy lifting in what we show you.",
            canContinue: chosen.count == requiredInterestCount,
            blockedHint: remaining > 0 ? "Choose \(remaining) more." : nil,
            onNext: {
                state.updateDraft { $0.step = 8 }
                path.append(.rendering)
            },
            onBack: { path.removeLast() }
        ) {
            VStack(alignment: .leading, spacing: 28) {
                BubbleGroup(
                    legend: "Interests",
                    hideLegend: true,
                    description: "\(chosen.count) of \(requiredInterestCount) selected"
                ) {
                    ForEach(interests) { interest in
                        let selected = chosen.contains(interest.id)
                        Bubble(
                            label: "\(interest.emoji) \(interest.label)",
                            isSelected: selected,
                            isDisabled: !selected && atLimit
                        ) {
                            toggleInterest(interest.id)
                        }
                    }
                }

                if !chosen.isEmpty {
                    VStack(alignment: .leading, spacing: 20) {
                        Text("Want to narrow any of these? Optional, but it sharpens your feed.")
                            .secondaryStyle()

                        ForEach(chosen, id: \.self) { id in
                            if let interest = interestByID[id] {
                                BubbleGroup(legend: interest.label) {
                                    ForEach(interest.subcategories) { sub in
                                        Bubble(
                                            label: sub.label,
                                            isSelected: state.draft.interestSubcategories.contains(sub.id),
                                            size: .small
                                        ) {
                                            state.updateDraft {
                                                $0.interestSubcategories =
                                                    toggleIn($0.interestSubcategories, sub.id)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .padding(.top, 24)
                    .overlay(alignment: .top) {
                        Rectangle().fill(Ramp.hairline).frame(height: 1)
                    }
                }
            }
        }
    }

    private func toggleInterest(_ id: ID) {
        let next = toggleIn(chosen, id)
        guard next.count <= requiredInterestCount else { return }
        state.updateDraft {
            $0.interests = next
            // Drop orphaned subcategories when an interest is removed.
            $0.interestSubcategories = $0.interestSubcategories.filter { sub in
                next.contains { sub.hasPrefix("\($0)/") }
            }
        }
    }
}
