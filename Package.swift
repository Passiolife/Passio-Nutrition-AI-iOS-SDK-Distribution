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
                      url: "https://github.com/Passiolife/Passio-Nutrition-AI-iOS-SDK-Distribution/raw/3.2.0/PassioNutritionAISDK.xcframework.zip",
                      checksum: "813a2210ca16ad228f682835b06b23ec2fe07d5edb34dfa79852c4b7b930a0a1")
    ]
)
