import LotivityKit
import SwiftUI

/// Each step is its own destination so the system back gesture works and the
/// draft resumes in place after a relaunch (FR-PROF-14).
enum OnboardingStep: Hashable {
    case name, accountType, heritage, languages, culture, relationship, interests, rendering
}

struct OnboardingFlow: View {
    /// Called once the profile is saved and the flow should hand back to the app.
    let onFinish: () -> Void

    @Environment(AppState.self) private var state
    @Environment(\.dismiss) private var dismiss
    @State private var path: [OnboardingStep] = []

    /// The stepper covers name → interests; the entry and rendering screens are
    /// not questions, so they are not steps.
    private let stepCount = 7

    var body: some View {
        NavigationStack(path: $path) {
            frame { EntryStep(path: $path, browse: finish) }
                .navigationDestination(for: OnboardingStep.self) { step in
                    frame { destination(step) }
                        .navigationBarBackButtonHidden(step == .rendering)
                }
        }
        .tint(.olive)
    }

    @ViewBuilder
    private func destination(_ step: OnboardingStep) -> some View {
        switch step {
        case .name: NameDobStep(path: $path)
        case .accountType: AccountTypeStep(path: $path)
        case .heritage: HeritageStep(path: $path)
        case .languages: LanguagesStep(path: $path)
        case .culture: CultureStep(path: $path)
        case .relationship: RelationshipStep(path: $path)
        case .interests: InterestsStep(path: $path)
        case .rendering: RenderingStep(onDone: finish)
        }
    }

    private func frame<Content: View>(@ViewBuilder _ content: () -> Content) -> some View {
        AppBackground {
            VStack(spacing: 0) {
                if !path.isEmpty && path.last != .rendering {
                    StepperBar(current: min(path.count - 1, stepCount - 1), total: stepCount)
                        .padding(.horizontal, Metrics.screenPad)
                        .padding(.top, 24)
                }
                content()
                    .padding(.horizontal, Metrics.screenPad)
            }
        }
        .toolbar(.hidden, for: .navigationBar)
    }

    private func finish() {
        onFinish()
        dismiss()
    }
}

/// The shared shell for a question: heading, the question itself, then a sticky
/// footer holding the one cream payoff action.
struct StepFrame<Content: View>: View {
    let title: String
    var subtitle: String?
    var canContinue: Bool = true
    var nextLabel: String = "Next"
    /// Shown only while the step is blocked — the exactly-6 interests gate.
    var blockedHint: String?
    var onNext: () -> Void
    var onBack: (() -> Void)?
    /// Optional skip for genuinely optional steps (FR-PROF-9, 10).
    var onSkip: (() -> Void)?
    @ViewBuilder var content: Content

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    VStack(alignment: .leading, spacing: 12) {
                        Text(title).screenTitleStyle()
                        if let subtitle {
                            Text(subtitle).secondaryStyle()
                        }
                    }
                    .padding(.top, 32)

                    content.padding(.vertical, 28)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .scrollIndicators(.hidden)

            VStack(spacing: 12) {
                if let blockedHint, !canContinue {
                    Text(blockedHint)
                        .eyebrowStyle()
                        .accessibilityAddTraits(.updatesFrequently)
                }
                Button(nextLabel, action: onNext)
                    .buttonStyle(CreamButtonStyle())
                    .disabled(!canContinue)
                HStack {
                    if let onBack {
                        Button("Back", action: onBack).buttonStyle(QuietButtonStyle())
                    }
                    Spacer()
                    if let onSkip {
                        Button("Skip", action: onSkip).buttonStyle(QuietButtonStyle())
                    }
                }
            }
            .padding(.top, 12)
            .padding(.bottom, 8)
            .background(Color.lotBG)
        }
    }
}
