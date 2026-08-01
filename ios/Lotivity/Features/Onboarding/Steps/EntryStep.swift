import LotivityKit
import SwiftUI

/// FR-PROF-1. Google and Apple resolve instantly to a mock identity in v0 —
/// there is no real auth to fail against.
struct EntryStep: View {
    @Binding var path: [OnboardingStep]
    /// "Look around first" — straight into the app, no profile, no wall.
    let browse: () -> Void

    @Environment(AppState.self) private var state

    var body: some View {
        VStack(spacing: 48) {
            Spacer(minLength: 0)

            VStack(spacing: 0) {
                RoundedRectangle(cornerRadius: 26, style: .continuous)
                    .fill(Color.olive)
                    .frame(width: 80, height: 80)
                    .overlay(Text("◍").font(.system(size: 34)).foregroundStyle(Color.ink))
                    .accessibilityHidden(true)
                    .padding(.bottom, 28)

                // The wordmark is a brand moment, so it keeps its capital.
                Text("Lotivity")
                    .font(.system(size: 38, weight: .semibold))
                    .tracking(-1.5)
                    .foregroundStyle(Color.cream)

                Text("Local Activities. At a Price Best for You.")
                    .eyebrowStyle()
                    .padding(.top, 14)

                Text("Replacing artificial exchanges with real experiences. It's not revolutionary — it's real intelligence.")
                    .secondaryStyle()
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: 304)
                    .padding(.top, 32)
            }

            Spacer(minLength: 0)

            VStack(spacing: 12) {
                Button("Continue with Google") { start(.google) }
                    .buttonStyle(CreamButtonStyle())
                Button("Continue with Apple") { start(.apple) }
                    .buttonStyle(GhostButtonStyle())
                Button("Look around first", action: browse)
                    .buttonStyle(QuietButtonStyle())
                Text("Guests can browse everything nearby. Attending, reviewing, and connecting need a profile.")
                    .font(.system(size: 12))
                    .foregroundStyle(Ramp.faint)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: 336)
                    .padding(.top, 4)
            }
        }
        .padding(.vertical, 40)
        .frame(maxWidth: .infinity)
    }

    private func start(_ method: OnboardingDraft.AuthMethod) {
        state.updateDraft {
            $0.authMethod = method
            $0.step = 1
        }
        path.append(.name)
    }
}
