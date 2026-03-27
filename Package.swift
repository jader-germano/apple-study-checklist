// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "AppleStudyChecklist",
    platforms: [
        .macOS(.v14),
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "AppleStudyChecklist",
            targets: ["AppleStudyChecklist"]
        )
    ],
    targets: [
        .target(
            name: "AppleStudyChecklist",
            path: "Sources/AppleStudyChecklist",
            resources: [
                .process("Resources")
            ]
        ),
        .testTarget(
            name: "AppleStudyChecklistTests",
            dependencies: ["AppleStudyChecklist"],
            path: "Tests/AppleStudyChecklistTests"
        )
    ]
)
