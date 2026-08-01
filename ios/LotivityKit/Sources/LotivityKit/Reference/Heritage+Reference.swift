import Foundation

public let continentLabels: [Continent: String] = [
    .northAmerica: "North America",
    .southAmerica: "South America",
    .europe: "Europe",
    .africa: "Africa",
    .asia: "Asia",
    .oceania: "Oceania",
]

public let continentOrder: [Continent] = [
    .northAmerica, .southAmerica, .europe, .africa, .asia, .oceania,
]

private func build(_ continent: Continent, _ entries: [(String, String)]) -> [Heritage] {
    entries.map { country, label in
        Heritage(
            id: "heritage:" + country.lowercased().replacingOccurrences(of: " ", with: "-"),
            label: label,
            continent: continent,
            country: country
        )
    }
}

/// ≥8 options per continent (FR-PROF-7).
public let heritages: [Heritage] =
    build(.northAmerica, [
        ("United States", "American"),
        ("Mexico", "Mexican"),
        ("Canada", "Canadian"),
        ("Jamaica", "Jamaican"),
        ("Haiti", "Haitian"),
        ("Dominican Republic", "Dominican"),
        ("Puerto Rico", "Puerto Rican"),
        ("Cuba", "Cuban"),
        ("Guatemala", "Guatemalan"),
        ("Trinidad and Tobago", "Trinidadian"),
    ])
    + build(.southAmerica, [
        ("Brazil", "Brazilian"),
        ("Colombia", "Colombian"),
        ("Argentina", "Argentine"),
        ("Peru", "Peruvian"),
        ("Venezuela", "Venezuelan"),
        ("Ecuador", "Ecuadorian"),
        ("Chile", "Chilean"),
        ("Bolivia", "Bolivian"),
        ("Uruguay", "Uruguayan"),
    ])
    + build(.europe, [
        ("Ireland", "Irish"),
        ("Italy", "Italian"),
        ("Poland", "Polish"),
        ("Germany", "German"),
        ("Greece", "Greek"),
        ("Portugal", "Portuguese"),
        ("Ukraine", "Ukrainian"),
        ("France", "French"),
        ("Spain", "Spanish"),
        ("United Kingdom", "British"),
        ("Albania", "Albanian"),
    ])
    + build(.africa, [
        ("Nigeria", "Nigerian"),
        ("Tanzania", "Tanzanian"),
        ("Ghana", "Ghanaian"),
        ("Ethiopia", "Ethiopian"),
        ("Kenya", "Kenyan"),
        ("Senegal", "Senegalese"),
        ("Egypt", "Egyptian"),
        ("Morocco", "Moroccan"),
        ("South Africa", "South African"),
        ("Somalia", "Somali"),
    ])
    + build(.asia, [
        ("China", "Chinese"),
        ("South Korea", "South Korean"),
        ("India", "Indian"),
        ("Philippines", "Filipino"),
        ("Japan", "Japanese"),
        ("Vietnam", "Vietnamese"),
        ("Pakistan", "Pakistani"),
        ("Bangladesh", "Bangladeshi"),
        ("Lebanon", "Lebanese"),
        ("Nepal", "Nepali"),
    ])
    + build(.oceania, [
        ("Australia", "Australian"),
        ("New Zealand", "New Zealander"),
        ("Samoa", "Samoan"),
        ("Fiji", "Fijian"),
        ("Tonga", "Tongan"),
        ("Papua New Guinea", "Papua New Guinean"),
        ("Guam", "Chamorro"),
        ("Hawaii", "Native Hawaiian"),
    ])

public let heritageByID: [ID: Heritage] = Dictionary(
    uniqueKeysWithValues: heritages.map { ($0.id, $0) }
)

public func heritagesByContinent(_ continent: Continent) -> [Heritage] {
    heritages.filter { $0.continent == continent }
}

public func heritageLabel(_ id: ID) -> String {
    heritageByID[id]?.label ?? id
}

/// Pre-filled during onboarding, so it rarely reflects a deliberate choice.
public let homeHeritageID: ID = "heritage:united-states"
