import Foundation

/// Partial profile captured during onboarding. Persisted on every change.
public struct OnboardingDraft: Codable, Hashable, Sendable {
    public enum AuthMethod: String, Codable, Sendable { case google, apple, guest }

    public var step: Int
    public var authMethod: AuthMethod?
    public var name: String
    /// `yyyy-MM-dd`, empty until answered.
    public var dob: String
    public var accountType: AccountType?
    public var heritage: [ID]
    public var languages: [String]
    public var cultureTags: [ID]
    public var relationshipStatus: String?
    public var interests: [ID]
    public var interestSubcategories: [ID]

    public init(
        step: Int = 0,
        authMethod: AuthMethod? = nil,
        name: String = "",
        dob: String = "",
        accountType: AccountType? = nil,
        heritage: [ID] = [],
        languages: [String] = ["English"],
        cultureTags: [ID] = [],
        relationshipStatus: String? = nil,
        interests: [ID] = [],
        interestSubcategories: [ID] = []
    ) {
        self.step = step
        self.authMethod = authMethod
        self.name = name
        self.dob = dob
        self.accountType = accountType
        self.heritage = heritage
        self.languages = languages
        self.cultureTags = cultureTags
        self.relationshipStatus = relationshipStatus
        self.interests = interests
        self.interestSubcategories = interestSubcategories
    }

    /// Builds the saved profile. Mirrors the web app's `completeOnboarding`.
    public func toUser(location: GeoPoint) -> User {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let type = accountType ?? .adult
        return User(
            id: "user:me",
            name: trimmed.isEmpty ? "Guest" : trimmed,
            dob: dob,
            generation: generationFromDob(dob),
            accountType: type,
            heritage: heritage,
            languages: languages,
            cultureTags: cultureTags,
            relationshipStatus: relationshipStatus,
            interests: interests,
            interestSubcategories: interestSubcategories,
            location: location,
            isGuest: authMethod == .guest,
            youthVerification: type == .youth ? YouthVerification(status: .pending) : nil
        )
    }
}

/// The identity used before anyone signs up. Ranking still works — with no
/// interests or heritage to match, the feed falls back to proximity, which is
/// exactly the "here's what's actually near you" pitch (PRD §9.3).
public func guestProfile(location: GeoPoint = defaultCenter) -> User {
    User(
        id: "user:guest",
        name: "Guest",
        dob: "",
        generation: .millennial,
        accountType: .adult,
        heritage: [],
        languages: ["English"],
        cultureTags: [],
        interests: [],
        interestSubcategories: [],
        location: location,
        isGuest: true
    )
}

/// Adds or removes an id — the shared behavior behind every multi-select.
public func toggleIn(_ list: [ID], _ id: ID) -> [ID] {
    list.contains(id) ? list.filter { $0 != id } : list + [id]
}
