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
                      url: "https://github.com/Passiolife/Passio-Nutrition-AI-iOS-SDK-Distribution/raw/3.1.1/PassioNutritionAISDK.xcframework.zip",
                      checksum: "bf97cc736df544e57de89d21090bfe55d1bdc1ce780edb597acc655bc4ded08f")
    ]
)
