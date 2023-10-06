//
//  PassioRepresentable.swift
//
//  Created by Zvika on 4/4/23.
//  Copyright © 2023 Passiolife Inc. All rights reserved.

import SwiftUI
import Combine
import PassioNutritionAISDK

struct FoodRecognitionResults {
    let candidates: FoodCandidates?
    let image: UIImage?
    let nutritionFacts: PassioNutritionFacts?
    let downloadingMessage: String?
}

class PassioResults: ObservableObject {
    var objectWillChange = PassthroughSubject<Void, Never>()
    var foodRecognitionResults: FoodRecognitionResults? {
        didSet {
            Task {@MainActor in
                self.objectWillChange.send()
            }
        }
    }
}

struct PassioRepresentable: UIViewControllerRepresentable {

    let passioResults: PassioResults

    class Coordinator: FoodRecognitionDelegate, PassioStatusDelegate {

        let passioResults: PassioResults
        var message: String? {
            didSet {
                    passioResults.foodRecognitionResults = FoodRecognitionResults(candidates: nil,
                                                                                  image: nil,
                                                                                  nutritionFacts: nil,
                                                                                  downloadingMessage: message)
            }
        }

        init(passioResults: PassioResults) {
            self.passioResults = passioResults
        }

        func recognitionResults(candidates: FoodCandidates?,
                                image: UIImage?,
                                nutritionFacts: PassioNutritionFacts?) {
                passioResults.foodRecognitionResults = FoodRecognitionResults(candidates: candidates,
                                                                              image: image,
                                                                              nutritionFacts: nutritionFacts,
                                                                              downloadingMessage: nil)
        }

        func passioStatusChanged(status: PassioStatus) {
            print("SDK Status = \(status)")
        }

        func passioProcessing(filesLeft: Int) {
            message = "Files left to Process \(filesLeft)"
        }

        func completedDownloadingAllFiles(filesLocalURLs: [PassioNutritionAISDK.FileLocalURL]) {
            message = "Completed downloading all files"
        }

        func completedDownloadingFile(fileLocalURL: PassioNutritionAISDK.FileLocalURL, filesLeft: Int) {
            message = "Files left to download \(filesLeft)"
        }

        func downloadingError(message: String) {
            self.message = ("Downloading error: \(message)")
        }

    }

    func makeCoordinator() -> Coordinator {
        Coordinator(passioResults: passioResults)
    }

    func makeUIViewController(context: Context) -> PassioViewController {
        let vc = PassioViewController()
        vc.delegate = context.coordinator
        vc.statusDelegate = context.coordinator
        return vc
    }

    func updateUIViewController(_ uiViewController: PassioViewController, context: Context) {
    }
}
