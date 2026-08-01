import LotivityKit
import SwiftUI

/// Card anatomy, top to bottom: eyebrow, title, place, chips, and the reason
/// row. The reason row is load-bearing — a card that cannot explain itself does
/// not ship (DESIGN_SPEC §4.1, FR-FEED-3).
struct EventCardView: View {
    let scored: ScoredEvent

    private var event: LotivityEvent { scored.event }

    var body: some View {
        SurfaceCard(padding: 0) {
            VStack(alignment: .leading, spacing: 12) {
                VStack(alignment: .leading, spacing: 12) {
                    HStack(alignment: .top, spacing: 12) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("\(Self.day.string(from: event.startsAt)) · \(Self.time.string(from: event.startsAt))")
                                .eyebrowStyle()
                            Text(event.title).cardTitleStyle()
                            HStack(spacing: 4) {
                                Text(event.neighborhood).secondaryStyle()
                                Text("·").secondaryStyle()
                                Text(String(format: "%.1f mi", scored.distanceMi))
                                    .numeralStyle()
                            }
                        }
                        Spacer(minLength: 0)
                        // A sponsor is informational — not the user's own aliveness.
                        if event.sponsoredBy != nil {
                            Chip(text: "Sponsored", tone: .info)
                        }
                    }

                    FlowLayout(spacing: 6, lineSpacing: 6) {
                        if let price = event.priceLabel {
                            Chip(text: price)
                        } else {
                            Chip(text: "Free", tone: .accent)
                        }
                        Chip(text: "\(event.attendeeIds.count) going")
                        if event.requiresGuardian {
                            Chip(text: "Guardian required", tone: .warn)
                        }
                    }
                }
                .padding(16)
                .padding(.bottom, scored.topFactors.isEmpty ? 0 : -12)

                // Separated by a luminance step rather than a rule (§1.4).
                if !scored.topFactors.isEmpty {
                    Text(scored.topFactors.map(\.reason).joined(separator: " · "))
                        .secondaryStyle()
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Ramp.laneB)
                }
            }
        }
        .accessibilityElement(children: .combine)
    }

    private static let day: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "en_US")
        f.setLocalizedDateFormatFromTemplate("EEE MMM d")
        return f
    }()

    private static let time: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "en_US")
        f.timeStyle = .short
        f.dateStyle = .none
        return f
    }()
}
