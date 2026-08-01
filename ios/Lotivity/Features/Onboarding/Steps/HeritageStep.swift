import LotivityKit
import SwiftUI

/// FR-PROF-7. Country of location is pre-filled; the rest nests by continent.
struct HeritageStep: View {
    @Binding var path: [OnboardingStep]
    @Environment(AppState.self) private var state
    @State private var query = ""

    private var selected: [ID] {
        state.draft.heritage.isEmpty ? [homeHeritageID] : state.draft.heritage
    }

    private var matches: [Heritage]? {
        let q = query.trimmingCharacters(in: .whitespaces).lowercased()
        guard !q.isEmpty else { return nil }
        return heritages.filter {
            $0.label.lowercased().contains(q) || $0.country.lowercased().contains(q)
        }
    }

    var body: some View {
        StepFrame(
            title: "Where's your family from?",
            subtitle: "This drives the local events and heritage nights we surface for you. Pick as many as fit.",
            onNext: {
                let picked = selected
                state.updateDraft {
                    $0.heritage = picked
                    $0.step = 4
                }
                path.append(.languages)
            },
            onBack: { path.removeLast() }
        ) {
            VStack(alignment: .leading, spacing: 24) {
                TextField("Search heritage", text: $query)
                    .font(.system(size: 15))
                    .foregroundStyle(Color.cream)
                    .autocorrectionDisabled()
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(Color.lotRaised, in: RoundedRectangle(cornerRadius: Radius.card, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: Radius.card, style: .continuous)
                            .strokeBorder(Ramp.ring, lineWidth: 1)
                    )
                    .accessibilityLabel("Search heritage")

                if let matches {
                    BubbleGroup(legend: "Search results") {
                        ForEach(matches) { heritage in
                            bubble(heritage)
                        }
                    }
                    if matches.isEmpty {
                        Text("No matches for \u{201C}\(query)\u{201D}.").secondaryStyle()
                    }
                } else {
                    ForEach(continentOrder, id: \.self) { continent in
                        BubbleGroup(legend: continentLabels[continent] ?? continent.rawValue) {
                            ForEach(heritagesByContinent(continent)) { heritage in
                                bubble(heritage)
                            }
                        }
                    }
                }
            }
        }
    }

    private func bubble(_ heritage: Heritage) -> some View {
        Bubble(label: heritage.label, isSelected: selected.contains(heritage.id), size: .small) {
            let next = toggleIn(selected, heritage.id)
            state.updateDraft { $0.heritage = next }
        }
    }
}
