import SwiftUI

/// Deferred tabs stay in the navigation so the shell is complete and later
/// milestones drop in without restructuring. Named honestly rather than hidden.
struct ComingSoonView: View {
    let title: String
    let message: String
    let milestone: String
    let back: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ScreenHeader(title: title) {
                Chip(text: milestone).padding(.top, 6)
            }

            SurfaceCard {
                VStack(alignment: .leading, spacing: 12) {
                    Text(message).bodyStyle()
                    Text("Not built yet — this MVP covers onboarding, For You, and the map.")
                        .secondaryStyle()
                    Button("Back to For You →", action: back)
                        .buttonStyle(LinkButtonStyle())
                }
            }
        }
    }
}
