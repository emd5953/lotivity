import Foundation

/// Faith and community are separate namespaces matched independently, but
/// onboarding shows them on one screen under two headings (PRD §9.1).
/// "Hindi" in the original concept notes was a language; the faith is Hindu.
public let faithTags: [CultureTag] = [
    CultureTag(id: "faith:christian", namespace: .faith, label: "Christian"),
    CultureTag(id: "faith:catholic", namespace: .faith, label: "Catholic"),
    CultureTag(id: "faith:jewish", namespace: .faith, label: "Jewish"),
    CultureTag(id: "faith:muslim", namespace: .faith, label: "Muslim"),
    CultureTag(id: "faith:hindu", namespace: .faith, label: "Hindu"),
    CultureTag(id: "faith:buddhist", namespace: .faith, label: "Buddhist"),
    CultureTag(id: "faith:sikh", namespace: .faith, label: "Sikh"),
    CultureTag(id: "faith:spiritual", namespace: .faith, label: "Spiritual"),
    CultureTag(id: "faith:secular", namespace: .faith, label: "Secular"),
]

public let communityTags: [CultureTag] = [
    CultureTag(id: "community:black", namespace: .community, label: "Black"),
    CultureTag(id: "community:latin", namespace: .community, label: "Latin"),
    CultureTag(id: "community:arab", namespace: .community, label: "Arab"),
    CultureTag(id: "community:asian", namespace: .community, label: "Asian"),
    CultureTag(id: "community:south-asian", namespace: .community, label: "South Asian"),
    CultureTag(id: "community:caribbean", namespace: .community, label: "Caribbean"),
    CultureTag(id: "community:african", namespace: .community, label: "African"),
    CultureTag(id: "community:indigenous", namespace: .community, label: "Indigenous"),
    CultureTag(id: "community:lgbtq", namespace: .community, label: "LGBTQ+"),
    CultureTag(id: "community:veteran", namespace: .community, label: "Veteran"),
    CultureTag(id: "community:newcomer", namespace: .community, label: "New to the city"),
]

public let cultureTags: [CultureTag] = faithTags + communityTags

public let cultureByID: [ID: CultureTag] = Dictionary(
    uniqueKeysWithValues: cultureTags.map { ($0.id, $0) }
)

public func cultureLabel(_ id: ID) -> String {
    cultureByID[id]?.label ?? id
}

public func isFaith(_ id: ID) -> Bool {
    id.hasPrefix("faith:")
}

public let relationshipStatuses: [String] = [
    "Single",
    "In a relationship",
    "Married",
    "Partnered",
    "Prefer not to say",
]

public let languages: [String] = [
    "English",
    "Spanish",
    "Mandarin",
    "Cantonese",
    "French",
    "Haitian Creole",
    "Russian",
    "Arabic",
    "Bengali",
    "Korean",
    "Hindi",
    "Urdu",
    "Yiddish",
    "Hebrew",
    "Italian",
    "Polish",
    "Portuguese",
    "Tagalog",
    "Vietnamese",
    "Japanese",
    "Greek",
    "Albanian",
    "Yoruba",
    "Twi",
    "Amharic",
    "Wolof",
    "Ukrainian",
    "German",
    "Punjabi",
    "Nepali",
]
