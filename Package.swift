// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "OpenSSLSPM",
    platforms: [
        .macOS(.v10_13),
        .iOS(.v16)
    ],

    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "OpenSSLSPM",
            targets: ["OpenSSLSPM", "openssl"]
        ),
        .library(
          name: "openssl",
          targets: ["openssl"]
        ),

    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "OpenSSLSPM"
        ),
//        .binaryTarget(
//          name: "openssl",
//          path: "openssl.xcframework"
//        ),
        .binaryTarget(
          name: "openssl",
          url: "https://fsmonitor.com/openssl2.xcframework.zip",
          checksum: "900f59032f70c322f12680323d2c1ec7873f7e513680dd3313378f44ec19187f"),
        .testTarget(
            name: "OpenSSLSPMTests",
            dependencies: ["OpenSSLSPM"]
        ),
    ]
)
