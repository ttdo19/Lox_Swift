// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Lox",
    products: [
            .library(
                name: "Lox-Swift",
                targets: ["Lox-Swift"]),
            .executable(
                name: "GenerateAst",
                targets: ["GenerateAst"]),
            .executable(
                name: "LoxCLI",
                targets: ["LoxCLI"])
    ],
    targets: [
        .target(name: "Lox-Swift"),
        .executableTarget(name: "GenerateAst"),
        .executableTarget(name: "LoxCLI", dependencies: ["Lox-Swift"])
    ]
)
