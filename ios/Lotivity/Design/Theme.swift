import SwiftUI

/// Cinema black, one olive accent. The palette lives here and nowhere else —
/// a full re-hue is a change to this file (DESIGN_SPEC §9). No view hardcodes a
/// color literal.
extension Color {
    init(hex: UInt32) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255,
            opacity: 1
        )
    }

    // Surfaces
    static let lotBG = Color(hex: 0x000000)
    static let lotSoft = Color(hex: 0x0E0E0E)
    static let lotRaised = Color(hex: 0x191918)
    static let lotRaised2 = Color(hex: 0x232322)

    // Brand
    static let cream = Color(hex: 0xF1ECE5)
    static let ink = Color(hex: 0x0A0A0A)
    static let olive = Color(hex: 0xA8C152)
    static let oliveHi = Color(hex: 0xBED56F)
    static let oliveLo = Color(hex: 0x8FA847)
    static let lotTeal = Color(hex: 0x7B9AAB)
    static let lotError = Color(hex: 0xDC2626)
    static let lotSuccess = Color(hex: 0x16A34A)

    // Categorical encoding only — map pins, club categories. No orange, ever.
    static let sand = Color(hex: 0xC9B08A)
    static let plum = Color(hex: 0x9B7FA6)
    static let slate = Color(hex: 0x8892A0)
    static let moss = Color(hex: 0x7E8F5A)
    static let clay = Color(hex: 0xA6766B)
}

/// The foreground ramp of DESIGN_SPEC §1.3 — built from cream, never white.
enum Ramp {
    static let full = Color.cream
    static let strong = Color.cream.opacity(0.85)
    static let muted = Color.cream.opacity(0.45)
    static let faint = Color.cream.opacity(0.30)
    static let hairline = Color.cream.opacity(0.09)
    static let ring = Color.cream.opacity(0.12)
    static let ringSoft = Color.cream.opacity(0.07)
    static let ringGhost = Color.cream.opacity(0.22)
    static let laneA = Color.cream.opacity(0.035)
    static let laneB = Color.cream.opacity(0.022)
}

enum Radius {
    static let card: CGFloat = 16
    static let sheet: CGFloat = 24
    static let bubble: CGFloat = 999
}

enum Motion {
    /// Smaller elements move faster (DESIGN_SPEC §3.3).
    static let press = Animation.easeOut(duration: 0.16)
    static let selection = Animation.easeInOut(duration: 0.18)
    static let card = Animation.easeOut(duration: 0.25)
}

// MARK: - Type

extension View {
    /// mono 500, 11pt, +0.08em, LOWERCASE. The single biggest tell of the
    /// system — `textCase` leaves the real string intact for VoiceOver.
    func eyebrowStyle(_ color: Color = Ramp.faint) -> some View {
        font(.system(size: 11, weight: .medium, design: .monospaced))
            .tracking(0.88)
            .textCase(.lowercase)
            .foregroundStyle(color)
    }

    func chipLabelStyle(_ color: Color = Ramp.muted) -> some View {
        font(.system(size: 10.5, weight: .medium, design: .monospaced))
            .tracking(0.63)
            .textCase(.lowercase)
            .foregroundStyle(color)
    }

    /// Display type is packed: tracking is negative and aggressive.
    func screenTitleStyle() -> some View {
        font(.system(size: 30, weight: .semibold))
            .tracking(-1.2)
            .foregroundStyle(Color.cream)
    }

    func sectionTitleStyle() -> some View {
        font(.system(size: 20, weight: .semibold))
            .tracking(-0.6)
            .foregroundStyle(Color.cream)
    }

    func cardTitleStyle() -> some View {
        font(.system(size: 17, weight: .semibold))
            .tracking(-0.34)
            .foregroundStyle(Color.cream)
    }

    func bodyStyle() -> some View {
        font(.system(size: 15))
            .lineSpacing(3.5)
            .foregroundStyle(Ramp.strong)
    }

    func secondaryStyle() -> some View {
        font(.system(size: 14))
            .foregroundStyle(Ramp.muted)
    }

    /// Counts, distances, radii, prices.
    func numeralStyle(size: CGFloat = 14, color: Color = Ramp.muted) -> some View {
        font(.system(size: size, design: .monospaced))
            .monospacedDigit()
            .foregroundStyle(color)
    }
}

/// A single centered column, black to the edges (DESIGN_SPEC §3.1).
/// Named `Metrics` rather than `Layout` — SwiftUI owns that name.
enum Metrics {
    static let maxWidth: CGFloat = 480
    static let screenPad: CGFloat = 20
}
