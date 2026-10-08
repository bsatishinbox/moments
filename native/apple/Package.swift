// swift-tools-version: 5.9
import PackageDescription
let package = Package(
    name: "MomentModel",
    products: [.library(name: "MomentModel", targets: ["MomentModel"])],
    targets: [
        .target(name: "MomentModel", path: "Shared", exclude: ["LifeStore.swift", "MomentStyle.swift"], sources: ["LifeSettings.swift"]),
        .testTarget(name: "MomentModelTests", dependencies: ["MomentModel"], path: "Tests")
    ]
)
