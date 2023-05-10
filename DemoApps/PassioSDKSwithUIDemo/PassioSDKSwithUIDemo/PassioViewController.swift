//
//  ViewController.swift
//  PassioSDKQuickStart
//
//  Created by zvika on 10/27/20.
//  Copyright © 2023 Passiolife Inc. All rights reserved.

import UIKit
import AVFoundation
import PassioNutritionAISDK

class PassioViewController: UIViewController {

    let passioSDK = PassioNutritionAI.shared
    var videoLayer: AVCaptureVideoPreviewLayer?
    weak var delegate: FoodRecognitionDelegate?
    weak var statusDelegate: PassioStatusDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        var passioConfig = PassioConfiguration(key: passioSDKKey)
        passioConfig.debugMode = 31418
        passioSDK.statusDelegate = self
        passioSDK.configure(passioConfiguration: passioConfig) { (status) in
            print("PassioSDK status = \(status)" )
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if AVCaptureDevice.authorizationStatus(for: .video) == .authorized {
            startFoodDetection()
        } else {
            AVCaptureDevice.requestAccess(for: .video) { (granted) in
                if granted {
                    DispatchQueue.main.async { self.startFoodDetection() }
                } else { print("The user didn't grant access to use camera")}
            }
        }
    }

    func startFoodDetection() {
        setupPreviewLayer()
        guard passioSDK.status.mode == .isReadyForDetection else { return }
        passioSDK.startFoodDetection(foodRecognitionDelegate: self) { (ready) in
            if !ready { print("SDK was not configured correctly") }
        }
    }

    func setupPreviewLayer() {
        guard videoLayer == nil else { return }
        if let videoLayer = passioSDK.getPreviewLayer() {
            self.videoLayer = videoLayer
            videoLayer.frame = view.bounds
            view.layer.insertSublayer(videoLayer, at: 0)
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        passioSDK.stopFoodDetection()
        videoLayer?.removeFromSuperlayer()
        videoLayer = nil
    }

}

extension PassioViewController: PassioStatusDelegate {
    
    func passioStatusChanged(status: PassioStatus) {
        statusDelegate?.passioStatusChanged(status: status)
        if status.mode == .isReadyForDetection {
            DispatchQueue.main.async {
                self.startFoodDetection()
            }
        }
    }

    func passioProcessing(filesLeft: Int) {
        statusDelegate?.passioProcessing(filesLeft: filesLeft)
    }

    func completedDownloadingAllFiles(filesLocalURLs: [FileLocalURL]) {
        statusDelegate?.completedDownloadingAllFiles(filesLocalURLs: filesLocalURLs)
    }

    func completedDownloadingFile(fileLocalURL: FileLocalURL, filesLeft: Int) {
        statusDelegate?.completedDownloadingFile(fileLocalURL: fileLocalURL,
                                                 filesLeft: filesLeft)
    }

    func downloadingError(message: String) {
        statusDelegate?.downloadingError(message: message)
    }
}

extension PassioViewController: FoodRecognitionDelegate {

    func recognitionResults(candidates: FoodCandidates?,
                            image: UIImage?,
                            nutritionFacts: PassioNutritionFacts?) {
        delegate?.recognitionResults(candidates: candidates,
                                     image: image,
                                     nutritionFacts: nutritionFacts)
    }

}
