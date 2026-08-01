import LotivityKit
import SwiftUI

struct ProfileView: View {
    let startOnboarding: () -> Void

    @Environment(AppState.self) private var state

    var body: some View {
        if let profile = state.profile {
            filled(profile)
        } else {
            guest
        }
    }

    // Guests reach this tab too — it's the pitch for signing up, not a dead end.
    private var guest: some View {
        VStack(alignment: .leading, spacing: 0) {
            ScreenHeader(title: "Profile", subtitle: "Browsing as a guest")
            SurfaceCard {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Nothing saved yet").cardTitleStyle()
                    Text("Guests can browse everything nearby. Setting up a profile is what gets you matched on heritage, faith, and interests — and lets you attend, review, and connect.")
                        .secondaryStyle()
                    Button("Set up your profile", action: startOnboarding)
                        .buttonStyle(CreamButtonStyle())
                }
            }
        }
    }

    private func filled(_ profile: User) -> some View {
        let accountType = accountTypes.first { $0.id == profile.accountType }
        let faiths = profile.cultureTags.filter(isFaith).map(cultureLabel)
        let communities = profile.cultureTags.filter { !isFaith($0) }.map(cultureLabel)

        return VStack(alignment: .leading, spacing: 16) {
            ScreenHeader(title: profile.name, subtitle: accountType?.label)

            SurfaceCard {
                VStack(alignment: .leading, spacing: 16) {
                    FlowLayout(spacing: 6, lineSpacing: 6) {
                        Chip(text: generationLabel(profile.generation), tone: .accent)
                        if profile.isGuest { Chip(text: "Guest", tone: .info) }
                        if let verification = profile.youthVerification {
                            Chip(
                                text: "Guardian verification \(verification.status.rawValue)",
                                tone: .warn
                            )
                        }
                    }
                    // The privacy promise is body copy, not fine print (§4.4).
                    Text("Your date of birth is never shown to anyone. Only your generation is.")
                        .bodyStyle()
                }
            }

            SurfaceCard {
                VStack(alignment: .leading, spacing: 20) {
                    TagRow(label: "Heritage", values: profile.heritage.map(heritageLabel))
                    TagRow(label: "Languages", values: profile.languages)
                    TagRow(label: "Faith", values: faiths)
                    TagRow(label: "Community", values: communities)
                    if let status = profile.relationshipStatus {
                        TagRow(label: "Relationship", values: [status])
                    }
                }
            }

            SurfaceCard {
                VStack(alignment: .leading, spacing: 20) {
                    TagRow(label: "Interests", values: profile.interests.map(interestLabel))
                    TagRow(
                        label: "More specifically",
                        values: profile.interestSubcategories.map(subcategoryLabel)
                    )
                }
            }

            SurfaceCard {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Settings").eyebrowStyle()
                    Button("Reset demo") { state.resetDemo() }
                        .buttonStyle(GhostButtonStyle())
                    Text("Clears your profile and everything stored on this device, then starts onboarding over.")
                        .secondaryStyle()
                }
            }
        }
    }
}

private struct TagRow: View {
    let label: String
    let values: [String]

    var body: some View {
        if !values.isEmpty {
            VStack(alignment: .leading, spacing: 8) {
                Text(label).eyebrowStyle()
                FlowLayout(spacing: 6, lineSpacing: 6) {
                    ForEach(values, id: \.self) { Chip(text: $0) }
                }
            }
        }
    }
}
