import Foundation

/// Curated name pools. Venue names are invented — no real business is implied.

let firstNames = [
    "Amara", "Diego", "Priya", "Marcus", "Yuki", "Rosa", "Tomas", "Nia", "Elias", "Fatima",
    "Jonah", "Leila", "Kwame", "Sofia", "Andre", "Mei", "Hassan", "Clara", "Devon", "Ingrid",
    "Rafael", "Aisha", "Nikolai", "Camille", "Omar", "Beatriz", "Sean", "Thandi", "Luca", "Hana",
    "Malik", "Elena", "Kofi", "Sadie", "Arjun", "Noor", "Gabriel", "Wren", "Tariq", "Josefina",
    "Emeka", "Marisol", "Bao", "Ruth", "Santiago", "Zaina", "Hugo", "Adaeze", "Mira", "Felix",
    "Imani", "Dmitri", "Paloma", "Jae", "Solomon", "Antonia", "Idris", "Greta", "Rashid", "Lucia",
    "Owen", "Chiara", "Nasir", "Esther", "Mateo", "Ayana",
]

let lastNames = [
    "Okafor", "Reyes", "Sharma", "Bell", "Tanaka", "Delgado", "Novak", "Achebe", "Moreau",
    "Haddad", "Whitfield", "Kim", "Osei", "Ferrara", "Duarte", "Chen", "Rahman", "Lindqvist",
    "Boateng", "Silva", "Kowalski", "Ali", "Mensah", "Petrova", "Nguyen", "Castellanos", "Byrne",
    "Mbeki", "Ricci", "Sato", "Adeyemi", "Vargas", "Asante", "Goldstein", "Patel", "Farah",
    "Santos", "Hollis", "Karim", "Barros", "Eze", "Navarro", "Tran", "Levy", "Ortiz", "Amin",
]

let venuePrefixes = [
    "Thornbury", "Marlow", "Bellweather", "Half Moon", "Copperline", "Gilded Fern", "Rook & Vine",
    "Northgate", "Little Anchor", "Amberline", "Fig & Slate", "Corner Lantern", "Blue Heron",
    "Stonefall", "Wildmoor", "Pennywhistle", "Harborlight", "Quill & Kettle", "Sablewood",
    "Morning Bell", "Cardinal", "Larkspur", "Ironwick", "Sunfield", "Verdant", "Old Mill",
]

let cafeSuffixes = ["Coffee", "Coffee House", "Roasters", "Café", "Espresso Bar"]
let restaurantSuffixes = ["Kitchen", "Table", "Cantina", "Grill", "Dining Room", "Taverna"]
let studioSuffixes = ["Studio", "Workshop", "Clay Works", "Atelier", "Makery"]
let venueSuffixes = ["Hall", "Commons", "Community Center", "Room", "Loft"]

let eventTitleTemplates: [ID: [String]] = [
    "interest:basketball": [
        "Weekend pickup at {place}",
        "Open gym run — all levels",
        "Sunrise shootaround",
        "3-on-3 ladder night",
    ],
    "interest:running": [
        "{neighborhood} run club — easy 5K",
        "Bridge loop long run",
        "Track intervals night",
        "Sunset shakeout run",
    ],
    "interest:reading": [
        "Book club: this month’s pick",
        "Silent reading hour at {place}",
        "Poetry night open floor",
        "Short story workshop",
    ],
    "interest:music": [
        "Open mic at {place}",
        "Local bands showcase",
        "Vinyl listening session",
        "Jazz in the back room",
        "Afrobeats night",
    ],
    "interest:pottery": [
        "Beginner wheel throwing",
        "Open studio + glazing",
        "Hand-building for two",
        "Mug-making afternoon",
    ],
    "interest:movies": [
        "Outdoor screening in the park",
        "Indie double feature",
        "Classics night + discussion",
        "Director Q&A screening",
    ],
    "interest:cooking": [
        "Heritage recipes potluck",
        "Dumpling folding class",
        "Bread baking basics",
        "Slow sauce cook-along",
    ],
    "interest:volunteering": [
        "Park cleanup crew",
        "Community fridge restock",
        "Senior center game afternoon",
        "Youth mentoring orientation",
    ],
    "interest:soccer": ["Pickup at the turf", "League match", "Match watch party"],
    "interest:art": ["Gallery walk", "Life drawing session", "Mural painting day", "Craft night"],
    "interest:yoga": ["Yoga in the park", "Gentle restorative class", "Morning flow"],
    "interest:chess": ["Park chess meetup", "Chess club night", "Blitz tournament"],
    "interest:dance": ["Salsa social", "Afrobeats dance class", "Ballroom basics", "Bachata night"],
    "interest:gardening": ["Community plot workday", "Seed swap", "Container gardening workshop"],
    "interest:cycling": ["Group ride to the water", "Bike repair clinic", "Morning commute convoy"],
    "interest:photography": ["Photo walk at golden hour", "Darkroom intro", "Critique night"],
]

let postBodies = [
    "Way better turnout than I expected. Already planning to come back next week.",
    "Met three people who live on my block. Four years here and I had no idea.",
    "The host made a point of introducing everyone. Small thing, made the whole night.",
    "Showed up alone and left with dinner plans. Worth the walk.",
    "Smaller group this time but that made it easier to actually talk.",
    "Food was the highlight honestly. Staff let us take over the back room.",
    "Good energy. Bring a jacket if you go, it runs cold in there.",
    "First time trying this and I was nervous for no reason. Everyone was welcoming.",
    "Ran into someone from my old job. The radius thing really does work.",
    "Would go again. Parking is rough, take the train.",
    "They comped the group coffee with the code. Felt like the app actually showed up for us.",
    "Low key one of the better evenings I have had this month.",
]

let groupNameTemplates = [
    "{neighborhood} {interest} Collective",
    "{interest} Club of {neighborhood}",
    "The {neighborhood} {interest} Circle",
    "{neighborhood} {interest} Regulars",
]

let requestTemplates = [
    "Looking for a place to meet weekly to talk about the Bible. Ten or so of us, weeknights.",
    "Anyone want to start a morning run group? Aiming for three days a week before work.",
    "Retired folks who play cards — looking for a spot that will let us sit a few hours.",
    "New parents in the neighborhood, looking for a daytime meetup that tolerates strollers.",
    "Want to start a Spanish conversation hour. All levels, no teacher, just practice.",
    "Looking for a quiet place for a small writing group. Sundays, two hours.",
    "Trying to organize a monthly potluck around heritage recipes. Need a space with a kitchen.",
    "Grad students looking for a weekly co-working evening somewhere with wifi and mercy.",
    "Pickup basketball crew needs an indoor court for the winter months.",
    "Want to restart the neighborhood chess night that died during the pandemic.",
]
