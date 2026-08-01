import Foundation

private func sub(_ parent: String, _ entries: [(String, String)]) -> [InterestSubcategory] {
    entries.map { InterestSubcategory(id: "\(parent)/\($0.0)", label: $0.1) }
}

/// Subcategories per FR-PROF-12. The first six mirror the concept notes.
public let interests: [Interest] = [
    Interest(
        id: "interest:basketball", label: "Basketball", emoji: "🏀",
        subcategories: sub("interest:basketball", [
            ("organized", "Organized play"),
            ("pickup", "Local pickup"),
            ("outdoor", "Outside court"),
            ("open-gym", "Open gym"),
        ])
    ),
    Interest(
        id: "interest:running", label: "Running", emoji: "🏃",
        subcategories: sub("interest:running", [
            ("club", "Run club"),
            ("trails", "Trails"),
            ("races", "Competitions"),
            ("casual", "Casual jogs"),
        ])
    ),
    Interest(
        id: "interest:reading", label: "Reading", emoji: "📚",
        subcategories: sub("interest:reading", [
            ("workshops", "Workshops"),
            ("book-clubs", "Book clubs"),
            ("quiet", "Quiet places"),
            ("poetry", "Poetry readings"),
        ])
    ),
    Interest(
        id: "interest:music", label: "Music", emoji: "🎶",
        subcategories: sub("interest:music", [
            ("concerts", "Concerts"),
            ("open-mic", "Open mic"),
            ("local-bands", "Local bands"),
            ("lessons", "Lessons"),
            ("jazz", "Jazz"),
            ("hip-hop", "Hip-hop"),
        ])
    ),
    Interest(
        id: "interest:pottery", label: "Pottery", emoji: "🏺",
        subcategories: sub("interest:pottery", [
            ("wheel", "Wheel throwing"),
            ("handbuilding", "Hand building"),
            ("glazing", "Glazing"),
            ("studio-time", "Open studio"),
        ])
    ),
    Interest(
        id: "interest:movies", label: "Movies", emoji: "🎬",
        subcategories: sub("interest:movies", [
            ("indie", "Indie screenings"),
            ("outdoor", "Outdoor films"),
            ("classics", "Classics"),
            ("discussion", "Film discussion"),
        ])
    ),
    Interest(
        id: "interest:cooking", label: "Cooking", emoji: "🍳",
        subcategories: sub("interest:cooking", [
            ("classes", "Classes"),
            ("potlucks", "Potlucks"),
            ("baking", "Baking"),
            ("heritage", "Heritage recipes"),
        ])
    ),
    Interest(
        id: "interest:volunteering", label: "Volunteering", emoji: "🤝",
        subcategories: sub("interest:volunteering", [
            ("food", "Food programs"),
            ("parks", "Parks & cleanups"),
            ("mentoring", "Mentoring"),
            ("seniors", "Senior support"),
        ])
    ),
    Interest(
        id: "interest:soccer", label: "Soccer", emoji: "⚽",
        subcategories: sub("interest:soccer", [
            ("pickup", "Pickup"),
            ("league", "League play"),
            ("watch", "Watch parties"),
        ])
    ),
    Interest(
        id: "interest:art", label: "Art", emoji: "🎨",
        subcategories: sub("interest:art", [
            ("galleries", "Galleries"),
            ("drawing", "Drawing sessions"),
            ("murals", "Public murals"),
            ("crafts", "Crafts"),
        ])
    ),
    Interest(
        id: "interest:yoga", label: "Yoga", emoji: "🧘",
        subcategories: sub("interest:yoga", [
            ("studio", "Studio classes"),
            ("park", "In the park"),
            ("gentle", "Gentle & restorative"),
        ])
    ),
    Interest(
        id: "interest:chess", label: "Chess", emoji: "♟️",
        subcategories: sub("interest:chess", [
            ("park", "Park tables"),
            ("club", "Chess club"),
            ("tournaments", "Tournaments"),
        ])
    ),
    Interest(
        id: "interest:dance", label: "Dance", emoji: "💃",
        subcategories: sub("interest:dance", [
            ("salsa", "Salsa & bachata"),
            ("afrobeats", "Afrobeats"),
            ("ballroom", "Ballroom"),
            ("classes", "Classes"),
        ])
    ),
    Interest(
        id: "interest:gardening", label: "Gardening", emoji: "🌿",
        subcategories: sub("interest:gardening", [
            ("community-plot", "Community plots"),
            ("workshops", "Workshops"),
            ("seed-swap", "Seed swaps"),
        ])
    ),
    Interest(
        id: "interest:cycling", label: "Cycling", emoji: "🚲",
        subcategories: sub("interest:cycling", [
            ("group-rides", "Group rides"),
            ("commuting", "Commuting"),
            ("repair", "Repair clinics"),
        ])
    ),
    Interest(
        id: "interest:photography", label: "Photography", emoji: "📷",
        subcategories: sub("interest:photography", [
            ("walks", "Photo walks"),
            ("film", "Film & darkroom"),
            ("critique", "Critique nights"),
        ])
    ),
]

public let interestByID: [ID: Interest] = Dictionary(
    uniqueKeysWithValues: interests.map { ($0.id, $0) }
)

public func interestLabel(_ id: ID) -> String {
    interestByID[id]?.label ?? id
}

public func subcategoryLabel(_ id: ID) -> String {
    guard let parent = id.split(separator: "/").first.map(String.init),
          let interest = interestByID[parent],
          let match = interest.subcategories.first(where: { $0.id == id })
    else { return id }
    return match.label
}

public let requiredInterestCount = 6
