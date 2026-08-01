import SwiftUI

// MARK: - Surfaces

/// Separation by surface lift plus an INSET ring — never an outer border, which
/// would shift layout between states (DESIGN_SPEC §1.4).
struct SurfaceCard<Content: View>: View {
    var padding: CGFloat = 16
    var ringColor: Color = Ramp.ringSoft
    @ViewBuilder var content: Content

    var body: some View {
        content
            .padding(padding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                LinearGradient(
                    colors: [.lotRaised2, .lotRaised],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: Radius.card, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: Radius.card, style: .continuous)
                    .strokeBorder(ringColor, lineWidth: 1)
            )
    }
}

// MARK: - The pill system (DESIGN_SPEC §5)

/// The one payoff action. Exactly one per screen — if a screen wants two, one of
/// them is not the payoff.
struct CreamButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 15.5, weight: .semibold))
            .foregroundStyle(Color.ink)
            .padding(.vertical, 14)
            .padding(.horizontal, 24)
            .frame(maxWidth: .infinity)
            .background(Color.cream, in: Capsule())
            .opacity(isEnabled ? 1 : 0.4)
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(Motion.press, value: configuration.isPressed)
    }
}

/// Ghost pills ring on the INSIDE, so hovering or pressing never changes the
/// pill's measured size.
struct GhostButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 15.5, weight: .semibold))
            .foregroundStyle(Color.cream)
            .padding(.vertical, 14)
            .padding(.horizontal, 24)
            .frame(maxWidth: .infinity)
            .overlay(
                Capsule().strokeBorder(
                    configuration.isPressed ? Color.cream.opacity(0.45) : Ramp.ringGhost,
                    lineWidth: 1
                )
            )
            .opacity(isEnabled ? 1 : 0.4)
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(Motion.press, value: configuration.isPressed)
    }
}

struct QuietButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 15, weight: .semibold))
            .foregroundStyle(configuration.isPressed ? Color.cream : Ramp.muted)
            .padding(.vertical, 10)
            .padding(.horizontal, 12)
            .animation(Motion.press, value: configuration.isPressed)
    }
}

/// An inline text link — the "→" affordances the web app uses inside cards.
struct LinkButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 14, weight: .medium))
            .foregroundStyle(configuration.isPressed ? Color.oliveHi : Color.olive)
            .underline()
    }
}

// MARK: - Bubbles

enum BubbleSize {
    case small, medium

    var font: Font {
        switch self {
        case .small: .system(size: 14)
        case .medium: .system(size: 15.5)
        }
    }

    var padding: (h: CGFloat, v: CGFloat) {
        switch self {
        case .small: (12, 7)
        case .medium: (16, 10)
        }
    }
}

/// The signature interaction of the product. Selection is an olive INSET ring
/// plus olive text, not an olive fill (DESIGN_SPEC §1.4): a filter row that
/// defaults to all-on would otherwise paint a whole band solid olive, and olive
/// that covers everything has stopped meaning "alive". Nothing reflows between
/// states either way.
struct Bubble: View {
    let label: String
    let isSelected: Bool
    var size: BubbleSize = .medium
    var isDisabled: Bool = false
    /// `.radio` for single-select groups, `.checkbox` for multi-select — real
    /// accessibility traits rather than styled buttons (NFR-7).
    var isExclusive: Bool = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(label)
                .font(size.font)
                .fontWeight(isSelected ? .medium : .regular)
                .foregroundStyle(isSelected ? Color.olive : Ramp.strong)
                .padding(.horizontal, size.padding.h)
                .padding(.vertical, size.padding.v)
                .background(
                    isSelected ? Color.olive.opacity(0.10) : Color.lotRaised,
                    in: Capsule()
                )
                .overlay(
                    Capsule().strokeBorder(isSelected ? Color.olive : Ramp.ring, lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
        .disabled(isDisabled)
        .opacity(isDisabled ? 0.4 : 1)
        .animation(Motion.selection, value: isSelected)
        .accessibilityAddTraits(isSelected ? [.isSelected] : [])
        .accessibilityValue(isSelected ? "selected" : "not selected")
        .accessibilityHint(isExclusive ? "Selects one option" : "Toggles this option")
    }
}

struct BubbleGroup<Content: View>: View {
    let legend: String
    /// Keeps the legend for assistive tech but takes it off screen.
    var hideLegend: Bool = false
    var description: String?
    @ViewBuilder var content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            if !hideLegend {
                Text(legend).eyebrowStyle()
            }
            if let description {
                Text(description).secondaryStyle()
            }
            FlowLayout(spacing: 8, lineSpacing: 8) {
                content
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel(legend)
    }
}

// MARK: - Chips

enum ChipTone {
    case neutral
    /// Olive is aliveness — reserved for what the user is or has chosen.
    case accent
    /// A sponsor is informational, not the user's own aliveness.
    case info
    case warn

    var foreground: Color {
        switch self {
        case .neutral: Ramp.muted
        case .accent: .olive
        case .info: .lotTeal
        case .warn: .lotError
        }
    }

    var background: Color {
        switch self {
        case .neutral: Color.cream.opacity(0.06)
        case .accent: Color.olive.opacity(0.15)
        case .info: Color.lotTeal.opacity(0.15)
        case .warn: Color.lotError.opacity(0.15)
        }
    }
}

struct Chip: View {
    let text: String
    var tone: ChipTone = .neutral

    var body: some View {
        Text(text)
            .chipLabelStyle(tone.foreground)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(tone.background, in: Capsule())
    }
}

// MARK: - Chrome

/// Progress is the one thing on an onboarding screen that is alive, so progress
/// is olive.
struct StepperBar: View {
    let current: Int
    let total: Int

    var body: some View {
        HStack(spacing: 6) {
            ForEach(0..<max(total, 1), id: \.self) { index in
                Capsule()
                    .fill(index <= current ? Color.olive : Ramp.ring)
                    .frame(height: 2)
            }
        }
        .animation(Motion.selection, value: current)
        .accessibilityElement()
        .accessibilityLabel("Step \(current + 1) of \(total)")
    }
}

struct ScreenHeader<Trailing: View>: View {
    let title: String
    var subtitle: String?
    @ViewBuilder var trailing: Trailing

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 10) {
                Text(title).screenTitleStyle()
                if let subtitle {
                    Text(subtitle).secondaryStyle()
                }
            }
            Spacer(minLength: 0)
            trailing
        }
        .padding(.top, 28)
        .padding(.bottom, 20)
    }
}

extension ScreenHeader where Trailing == EmptyView {
    init(title: String, subtitle: String? = nil) {
        self.init(title: title, subtitle: subtitle) { EmptyView() }
    }
}

struct EmptyStateCard: View {
    let title: String
    let message: String

    var body: some View {
        SurfaceCard {
            VStack(spacing: 6) {
                Text(title).cardTitleStyle()
                Text(message).secondaryStyle().multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
        }
    }
}

// MARK: - Atmosphere

/// Film grain, one atmosphere for the whole app. Without it a pure-black UI
/// reads as a dead panel rather than as a dark room (DESIGN_SPEC §6).
struct FilmGrain: View {
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency

    var body: some View {
        if !reduceTransparency {
            Canvas { context, size in
                // A fixed lattice of specks: cheap, static, and stable across
                // redraws, which a random-per-frame noise would not be.
                var seed: UInt64 = 0x9E37_79B9_7F4A_7C15
                func nextUnit() -> Double {
                    seed ^= seed << 13
                    seed ^= seed >> 7
                    seed ^= seed << 17
                    return Double(seed % 10_000) / 10_000
                }
                let count = Int(size.width * size.height / 90)
                for _ in 0..<count {
                    let rect = CGRect(
                        x: nextUnit() * size.width,
                        y: nextUnit() * size.height,
                        width: 1,
                        height: 1
                    )
                    context.fill(Path(rect), with: .color(.white.opacity(nextUnit())))
                }
            }
            .blendMode(.screen)
            .opacity(0.045)
            .allowsHitTesting(false)
            .ignoresSafeArea()
        }
    }
}

/// The app frame: black to the edges, one centered column, grain over
/// everything.
struct AppBackground<Content: View>: View {
    @ViewBuilder var content: Content

    var body: some View {
        ZStack {
            Color.lotBG.ignoresSafeArea()
            content
                .frame(maxWidth: Metrics.maxWidth)
                .frame(maxWidth: .infinity)
            FilmGrain()
        }
        .preferredColorScheme(.dark)
        .tint(.olive)
    }
}
