// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AlignedCollectionViewFlowLayout",
    products: [
        .library(
            name: "AlignedCollectionViewFlowLayout",
            targets: ["AlignedCollectionViewFlowLayout"])
    ],
    targets: [
        .target(
            name: "AlignedCollectionViewFlowLayout",
            path: "AlignedCollectionViewFlowLayout")
    ]
)
