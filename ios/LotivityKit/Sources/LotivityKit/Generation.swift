import Foundation

public struct GenerationDef: Sendable, Identifiable {
    public let id: Generation
    public let label: String
    /// Inclusive birth-year range.
    public let from: Int
    public let to: Int
}

/// Pew-style boundaries. Generation is shown; the DOB behind it is not (PRD §9.4).
public let generations: [GenerationDef] = [
    GenerationDef(id: .silent, label: "Silent Generation", from: 1928, to: 1945),
    GenerationDef(id: .boomer, label: "Baby Boomer", from: 1946, to: 1964),
    GenerationDef(id: .genx, label: "Gen X", from: 1965, to: 1980),
    GenerationDef(id: .millennial, label: "Millennial", from: 1981, to: 1996),
    GenerationDef(id: .genz, label: "Gen Z", from: 1997, to: 2012),
    GenerationDef(id: .alpha, label: "Gen Alpha", from: 2013, to: 2100),
]

private let generationByID: [Generation: GenerationDef] = Dictionary(
    uniqueKeysWithValues: generations.map { ($0.id, $0) }
)

/// A `yyyy-MM-dd` string is read as calendar components, not as an instant, so
/// the answer never depends on the device's time zone.
func birthYear(from dob: String) -> Int? {
    let parts = dob.split(separator: "-", omittingEmptySubsequences: false)
    guard parts.count == 3, parts[0].count == 4, let year = Int(parts[0]) else { return nil }
    guard let month = Int(parts[1]), (1...12).contains(month),
          let day = Int(parts[2]), (1...31).contains(day) else { return nil }
    return year
}

public func generationFromDob(_ dob: String) -> Generation {
    guard let year = birthYear(from: dob) else { return .millennial }
    // Anything before the Silent Generation still reads as the oldest cohort.
    return generations.first { year >= $0.from && year <= $0.to }?.id ?? .silent
}

public func generationLabel(_ id: Generation) -> String {
    generationByID[id]?.label ?? "Unknown"
}

private let utcCalendar: Calendar = {
    var cal = Calendar(identifier: .gregorian)
    cal.timeZone = TimeZone(secondsFromGMT: 0)!
    return cal
}()

public func ageFromDob(_ dob: String, now: Date = Date()) -> Int {
    let parts = dob.split(separator: "-").compactMap { Int($0) }
    guard parts.count == 3 else { return 0 }
    let nowParts = utcCalendar.dateComponents([.year, .month, .day], from: now)
    guard let nowYear = nowParts.year, let nowMonth = nowParts.month, let nowDay = nowParts.day else {
        return 0
    }

    var age = nowYear - parts[0]
    let monthDiff = nowMonth - parts[1]
    if monthDiff < 0 || (monthDiff == 0 && nowDay < parts[2]) { age -= 1 }
    return age
}

public struct AccountTypeDef: Sendable, Identifiable {
    public let id: AccountType
    public let label: String
    public let blurb: String
}

public let accountTypes: [AccountTypeDef] = [
    AccountTypeDef(
        id: .youth,
        label: "Youth",
        blurb: "Events need a community-appointed host or parent who has verified their ID."
    ),
    AccountTypeDef(
        id: .adult,
        label: "General adult",
        blurb: "Full access to groups, events, and connections in your radius."
    ),
    AccountTypeDef(
        id: .retired,
        label: "Retired",
        blurb: "Weighted toward recurring, daytime gatherings near you."
    ),
]

/// Suggests an account type from age so the choice starts sensible, not blank.
public func suggestAccountType(_ dob: String, now: Date = Date()) -> AccountType {
    let age = ageFromDob(dob, now: now)
    if age < 18 { return .youth }
    if age >= 66 { return .retired }
    return .adult
}
