// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "PassioNutritionAISDK",
    products: [
        .library(
            name: "PassioNutritionAISDK",
            targets: ["PassioNutritionAISDK"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .binaryTarget(name: "PassioNutritionAISDK",
                      url: "https://github.com/Passiolife/Passio-Nutrition-AI-iOS-SDK-Distribution/blob/2.3.1/PassioNutritionAISDK.xcframework.zip",
                      checksum: "682414ceec1837539f7e0ef645057b653bd061bc65b5b03c35c1fe96d762f459")
    ]
)
