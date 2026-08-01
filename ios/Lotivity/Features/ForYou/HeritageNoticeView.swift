import LotivityKit
import SwiftUI

/// FR-FEED-4 — the heritage notification voice from the concept notes, e.g.
/// "This Friday, check out Colombian restaurant ___ for happy hour."
struct HeritageNoticeView: View {
    let pick: HeritagePick

    var body: some View {
        SurfaceCard(ringColor: Color.olive.opacity(0.25)) {
            VStack(alignment: .leading, spacing: 12) {
                Chip(text: "\(pick.heritageLabel) heritage", tone: .accent)

                (
                    Text("This \(pick.weekday), check out \(pick.heritageLabel) spot ")
                        .font(.system(size: 17))
                        .foregroundColor(.cream)
                    + Text(pick.business.name)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.cream)
                    + Text(" for happy hour in \(pick.business.neighborhood).")
                        .font(.system(size: 17))
                        .foregroundColor(.cream)
                )
                .lineSpacing(2)

                HStack(spacing: 4) {
                    Text("\(pick.positiveVotes)").numeralStyle()
                    Text("people with \(pick.heritageLabel) heritage voted it a positive experience this past week.")
                        .secondaryStyle()
                }
                .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}
