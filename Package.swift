// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "PassioNutritionAISDK",
    platforms: [.iOS(.v13)
    ],
    products: [
        .library(
            name: "PassioNutritionAISDK",
            targets: ["PassioNutritionAISDK"])
    ],
    targets: [
        .binaryTarget(name: "PassioNutritionAISDK",
                      url: "https://github.com/Passiolife/Passio-Nutrition-AI-iOS-SDK-Distribution/branch/test/3.2.2/PassioNutritionAISDK.xcframework.zip",
                      checksum: "ef472088bac3b4a08214514c72f04877567e3358bb7e4a9e2495a8c94e5c243c")
    ]
)
