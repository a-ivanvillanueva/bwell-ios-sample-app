// swift-tools-version: 5.9

import PackageDescription

// A stand-in for the private b.well SDK so the sample app can build and run
// with example data. IT is NOT the real SDK.

let package = Package(
    name: "BWellSDK",
    platforms: [.iOS(.v17)],
    products: [
        .library(name: "BWellSDK", targets: ["BWellSDK"])
    ],
    targets: [
        .target(name: "BWellSDK")
    ]
)
