import SwiftUI

/// FR-PROF-13. Deliberately ~3s — long enough to feel like work happened.
struct RenderingStep: View {
    let onDone: () -> Void

    @Environment(AppState.self) private var state
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var line = 0
    @State private var spinning = false

    private let lines = [
        "Reading your radius…",
        "Finding people who share your interests…",
        "Checking what your heritage communities are up to…",
        "Sorting what is actually worth leaving the house for…",
    ]

    var body: some View {
        VStack(spacing: 0) {
            Circle()
                .trim(from: 0, to: 0.75)
                .stroke(Color.olive, style: StrokeStyle(lineWidth: 2, lineCap: .round))
                .background(Circle().strokeBorder(Ramp.ring, lineWidth: 2))
                .frame(width: 64, height: 64)
                .rotationEffect(.degrees(spinning ? 360 : 0))
                // Reduced motion disables every loop animation (DESIGN_SPEC §3.3).
                .animation(
                    reduceMotion ? nil : .linear(duration: 1).repeatForever(autoreverses: false),
                    value: spinning
                )
                .accessibilityHidden(true)
                .padding(.bottom, 32)

            Text("Rendering your community…").sectionTitleStyle()

            Text(lines[min(line, lines.count - 1)])
                .font(.system(size: 15))
                .foregroundStyle(Ramp.muted)
                .padding(.top, 14)
                .frame(height: 22)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .task {
            spinning = true
            state.completeOnboarding()

            for index in 1..<lines.count {
                try? await Task.sleep(for: .milliseconds(700))
                line = index
            }
            try? await Task.sleep(for: .milliseconds(3_000 - 700 * (lines.count - 1)))
            onDone()
        }
    }
}
