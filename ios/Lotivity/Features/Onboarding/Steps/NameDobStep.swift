import LotivityKit
import SwiftUI

/// FR-PROF-2, FR-PROF-3. DOB is collected to derive generation, never shown.
struct NameDobStep: View {
    @Binding var path: [OnboardingStep]
    @Environment(AppState.self) private var state

    @State private var name = ""
    @State private var birthDate = Calendar.current.date(from: DateComponents(year: 1995, month: 1, day: 1))!
    @State private var hasSetDate = false

    private var generation: Generation? {
        hasSetDate ? generationFromDob(Self.isoDay.string(from: birthDate)) : nil
    }

    var body: some View {
        StepFrame(
            title: "Let's start with you",
            subtitle: "Your name and generation are visible to others. Your date of birth is not.",
            canContinue: name.trimmingCharacters(in: .whitespaces).count > 1 && hasSetDate,
            blockedHint: "Add your name and date of birth to continue.",
            onNext: {
                state.updateDraft {
                    $0.name = name
                    $0.dob = Self.isoDay.string(from: birthDate)
                    $0.step = 2
                }
                path.append(.accountType)
            },
            onBack: { path.removeLast() }
        ) {
            VStack(alignment: .leading, spacing: 24) {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Name").eyebrowStyle()
                    TextField("Your name", text: $name)
                        .textContentType(.name)
                        .font(.system(size: 17))
                        .foregroundStyle(Color.cream)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 14)
                        .background(Color.lotRaised, in: RoundedRectangle(cornerRadius: Radius.card, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: Radius.card, style: .continuous)
                                .strokeBorder(Ramp.ring, lineWidth: 1)
                        )
                }

                VStack(alignment: .leading, spacing: 10) {
                    Text("Date of birth").eyebrowStyle()
                    DatePicker(
                        "Date of birth",
                        selection: $birthDate,
                        in: Self.earliest...Self.latest,
                        displayedComponents: .date
                    )
                    .datePickerStyle(.compact)
                    .labelsHidden()
                    .onChange(of: birthDate) { hasSetDate = true }

                    Text("Never shown to anyone. We use it to work out your generation, which is.")
                        .secondaryStyle()
                }

                if let generation {
                    SurfaceCard {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Others will see").eyebrowStyle()
                            HStack(spacing: 8) {
                                Text(name.trimmingCharacters(in: .whitespaces).isEmpty ? "Your name" : name)
                                    .cardTitleStyle()
                                Chip(text: generationLabel(generation), tone: .accent)
                            }
                        }
                    }
                }
            }
        }
        .onAppear {
            name = state.draft.name
            if let saved = Self.isoDay.date(from: state.draft.dob) {
                birthDate = saved
                hasSetDate = true
            }
        }
    }

    private static let isoDay: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "en_US_POSIX")
        f.calendar = Calendar(identifier: .gregorian)
        f.dateFormat = "yyyy-MM-dd"
        return f
    }()

    private static let earliest = Calendar.current.date(from: DateComponents(year: 1920, month: 1, day: 1))!
    private static let latest = Calendar.current.date(from: DateComponents(year: 2020, month: 12, day: 31))!
}
