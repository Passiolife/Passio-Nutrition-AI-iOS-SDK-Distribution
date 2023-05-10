//
//  PassioRepresentable.swift
//
//  Created by Zvika on 4/4/23.
//  Copyright © 2023 Passiolife Inc. All rights reserved.

import SwiftUI
import PassioNutritionAISDK

struct PassioRepresentable: UIViewControllerRepresentable {

    let foodBinder: Binding<FoodRecognitionBinder?>
    let messagesBinder: Binding<String?>
    let sdkConfigured: Binding<Bool>

    class Coordinator: FoodRecognitionDelegate, PassioStatusDelegate {
        
        let foodBinder: Binding<FoodRecognitionBinder?>
        let messagesBinder: Binding<String?>
        let sdkConfigured: Binding<Bool>
        
        init(foodBinder: Binding<FoodRecognitionBinder?>,
             messagesBinder: Binding<String?>,
             sdkConfigured: Binding<Bool>) {
            self.foodBinder = foodBinder
            self.messagesBinder = messagesBinder
            self.sdkConfigured = sdkConfigured
        }
        
        func recognitionResults(candidates: FoodCandidates?,
                                image: UIImage?,
                                nutritionFacts: PassioNutritionFacts?) {
            messagesBinder.wrappedValue = nil
            foodBinder.wrappedValue = FoodRecognitionBinder(candidates: candidates,
                                                          image: image,
                                                          nutritionFacts: nutritionFacts)
        }
        
        func passioStatusChanged(status: PassioStatus) {
            print("SDK Status = \(status)")
            if status.mode == .isReadyForDetection {
                sdkConfigured.wrappedValue = true
            }
        }
        
        func passioProcessing(filesLeft: Int) {
            messagesBinder.wrappedValue = "Files left to Process \(filesLeft)"
        }
        
        func completedDownloadingAllFiles(filesLocalURLs: [PassioNutritionAISDK.FileLocalURL]) {
            messagesBinder.wrappedValue = "Completed downloading all files"
        }
        
        func completedDownloadingFile(fileLocalURL: PassioNutritionAISDK.FileLocalURL, filesLeft: Int) {
            messagesBinder.wrappedValue = "Files left to download \(filesLeft)"
        }
        
        func downloadingError(message: String) {
            messagesBinder.wrappedValue = ("Downloading error: \(message)")
        }
        
        
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(foodBinder: foodBinder,
                    messagesBinder: messagesBinder,
                    sdkConfigured: sdkConfigured)
    }

    func makeUIViewController(context: Context) -> PassioViewController {
        let vc = PassioViewController()
        vc.delegate = context.coordinator
        vc.statusDelegate = context.coordinator
        return vc
    }

    func updateUIViewController(_ uiViewController: PassioViewController, context: Context) {
        // Updates the state of the specified view controller with new information from SwiftUI.
    }
}

struct FoodRecognitionBinder {
    let candidates: FoodCandidates?
    let image: UIImage?
    let nutritionFacts: PassioNutritionFacts?
}
