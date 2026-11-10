// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "KanoNaviKit",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v26),
        // macOS lets `swift test` run the Foundation-only core on the host.
        .macOS(.v26),
    ],
    products: [
        .library(name: "KanoNaviCore", targets: ["KanoNaviCore"]),
        .library(name: "KanoNaviComponents", targets: ["KanoNaviComponents"]),
    ],
    targets: [
        .target(name: "KanoNaviCore", resources: [.process("Resources")]),
        .target(
            name: "KanoNaviComponents",
            dependencies: ["KanoNaviCore"],
            resources: [.process("Resources")],
            swiftSettings: [.defaultIsolation(MainActor.self)]
        ),
        .testTarget(
            name: "KanoNaviCoreTests", dependencies: ["KanoNaviCore"], resources: [.process("Fixtures")]),
        .testTarget(name: "KanoNaviComponentsTests", dependencies: ["KanoNaviComponents"]),
    ]
)
