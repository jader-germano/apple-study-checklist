// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "AppleStudyChecklist",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .executable(
            name: "AppleStudyChecklist",
            targets: ["AppleStudyChecklist"]
        )
    ],
    targets: [
        .executableTarget(
            name: "AppleStudyChecklist",
            path: "Sources/AppleStudyChecklist"
        )
    ]
)
