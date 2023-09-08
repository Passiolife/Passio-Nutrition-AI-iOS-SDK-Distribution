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
                      url: "https://github.com/Passiolife/Passio-Nutrition-AI-iOS-SDK-Distribution/raw/2.3.9/PassioNutritionAISDK.xcframework.zip",
                      checksum: "785e32955e405de37d436bdf5155fe85637f1c864055eaca03ae3c06a08ac765")
    ]
)
