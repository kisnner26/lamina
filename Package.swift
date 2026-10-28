// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "Lamina",
    platforms: [.macOS(.v15)],
    products: [
        .executable(name: "Lamina", targets: ["Lamina"])
    ],
    targets: [
        .executableTarget(name: "Lamina"),
        .testTarget(
            name: "LaminaTests",
            dependencies: ["Lamina"]
        )
    ]
)
