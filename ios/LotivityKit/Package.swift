// swift-tools-version:6.0
import PackageDescription

// The domain layer lives in a package rather than the app target so `swift test`
// runs it without a simulator, and so nothing in it can reach for SwiftUI.
let package = Package(
    name: "LotivityKit",
    platforms: [.iOS(.v17), .macOS(.v14)],
    products: [
        .library(name: "LotivityKit", targets: ["LotivityKit"]),
    ],
    targets: [
        .target(
            name: "LotivityKit",
            swiftSettings: [.swiftLanguageMode(.v5)]
        ),
        .testTarget(
            name: "LotivityKitTests",
            dependencies: ["LotivityKit"],
            swiftSettings: [.swiftLanguageMode(.v5)]
        ),
    ]
)
