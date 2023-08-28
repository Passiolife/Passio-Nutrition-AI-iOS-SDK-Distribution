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
                      url: "https://github.com/Passiolife/Passio-Nutrition-AI-iOS-SDK-Distribution/raw/2.3.8/PassioNutritionAISDK.xcframework.zip",
                      checksum: "c6613abef021eea7b2cd5193afb653bcbbeffc849f5c3887036c2cc0614b65fa")
    ]
)
