import LotivityKit
import SwiftUI

/// FR-PROF-4, 5, 6.
struct AccountTypeStep: View {
    @Binding var path: [OnboardingStep]
    @Environment(AppState.self) private var state

    private var selected: AccountType? {
        state.draft.accountType
            ?? (state.draft.dob.isEmpty ? nil : suggestAccountType(state.draft.dob))
    }

    var body: some View {
        let active = accountTypes.first { $0.id == selected }

        StepFrame(
            title: "Which fits your life right now?",
            canContinue: selected != nil,
            onNext: {
                state.updateDraft {
                    $0.accountType = selected
                    $0.step = 3
                }
                path.append(.heritage)
            },
            onBack: { path.removeLast() }
        ) {
            VStack(alignment: .leading, spacing: 20) {
                BubbleGroup(legend: "Account type", hideLegend: true) {
                    ForEach(accountTypes) { type in
                        Bubble(
                            label: type.label,
                            isSelected: selected == type.id,
                            isExclusive: true
                        ) {
                            state.updateDraft { $0.accountType = type.id }
                        }
                    }
                }

                if let active {
                    Text(active.blurb)
                        .font(.system(size: 15))
                        .foregroundStyle(Color.cream.opacity(0.6))
                }

                // FR-PROF-5 — the incentive is stated plainly rather than buried.
                SurfaceCard {
                    Text("Community promotions are matched to these categories. Picking the one that actually reflects your life is what gets you the discounts and gatherings meant for you.")
                        .secondaryStyle()
                }

                if selected == .youth {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Youth accounts need a verified adult").cardTitleStyle()
                        Text("Any event you host or attend needs a community-appointed host or parent who has verified their ID. We'll walk you through it after setup.")
                            .font(.system(size: 14))
                            .foregroundStyle(Color.cream.opacity(0.6))
                    }
                    .padding(16)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.olive.opacity(0.10), in: RoundedRectangle(cornerRadius: Radius.card, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: Radius.card, style: .continuous)
                            .strokeBorder(Color.olive.opacity(0.30), lineWidth: 1)
                    )
                }
            }
        }
    }
}
