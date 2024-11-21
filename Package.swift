// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "KMLKit",
    platforms: [
        .macOS(.v10_13),
        .iOS(.v14)
    ],
    products: [
        .library(name: "KMLKit", targets: ["KMLKit"]),
    ],
    dependencies: [
        .package(url: "https://github.com/weichsel/ZIPFoundation.git", from: "0.9.12")
    ],
    targets: [
        .target(name: "ExceptionHelper"),
        .target(
            name: "KMLKit",
            dependencies: ["ExceptionHelper", "ZIPFoundation"],
            cSettings: [
                .headerSearchPath("include")
            ]
        ),
        .testTarget(
            name: "KMLKitTests",
            dependencies: ["KMLKit"],
            resources: [
                .copy("Resources")
            ]
        ),
    ]
)
