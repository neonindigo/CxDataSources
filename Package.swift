// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "CxDataSources",
    platforms: [.iOS(.v15), .macOS(.v12)],
    products: [
        .library(name: "CxDataSources", targets: ["CxDataSources"]),
    ],
    dependencies: [
        // Differentiator: the diff engine (zero external deps) from RxDataSources repo
        .package(url: "https://github.com/RxSwiftCommunity/RxDataSources", from: "5.0.0"),
    ],
    targets: [
        .target(
            name: "CxDataSources",
            dependencies: [
                .product(name: "Differentiator", package: "RxDataSources"),
            ]
        ),
        .testTarget(
            name: "CxDataSourcesTests",
            dependencies: ["CxDataSources"]
        ),
    ]
)
