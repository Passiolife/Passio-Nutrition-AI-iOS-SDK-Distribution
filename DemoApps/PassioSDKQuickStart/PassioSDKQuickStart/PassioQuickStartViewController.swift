//
//  ViewController.swift
//  PassioSDKQuickStart
//
//  Created by zvika on 10/27/20.
//  Copyright © 2023 Passiolife Inc. All rights reserved.

import UIKit
import AVFoundation
import PassioNutritionAISDK

class PassioQuickStartViewController: UIViewController {

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var labelForPassioIDs: UILabel!

    let passioSDK = PassioNutritionAI.shared
    var videoLayer: AVCaptureVideoPreviewLayer?
    var passioRunning = false

    override func viewDidLoad() {
        super.viewDidLoad()
        let passioConfig = PassioConfiguration(key: passioSDKKey)
        passioSDK.statusDelegate = self
        passioSDK.configure(passioConfiguration: passioConfig) { (status) in
            print("Mode = \(status.mode)\nmissingfiles = \(String(describing: status.missingFiles))" )
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
        guard passioSDK.status.mode == .isReadyForDetection,
        !passioRunning else { return }
        passioRunning = true
        DispatchQueue.global(qos: .userInitiated).async {
            self.passioSDK.startFoodDetection(foodRecognitionDelegate: self) { (ready) in
                if !ready { print("SDK was not configured correctly") }
                
            }
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

extension PassioQuickStartViewController: FoodRecognitionDelegate {

    func recognitionResults(candidates: FoodCandidates?,
                            image: UIImage?,
                            nutritionFacts: PassioNutritionFacts?) {

        // print("candidates.count = \(candidates?.detectedCandidates.count)" )

        if let detectedCandidates = candidates?.detectedCandidates, !detectedCandidates.isEmpty {
            var message = "\n"
            detectedCandidates.forEach {
                if let pidAtt = self.passioSDK.lookupPassioIDAttributesFor(passioID: $0.passioID) {
                    message += pidAtt.name + "\n"
                    print("Food name =\(pidAtt.name)")
                }
            }
            DispatchQueue.main.async {
                self.labelForPassioIDs.text = message
                self.activityIndicator.stopAnimating()
            }
        } else {
            DispatchQueue.main.async {
                self.stillScanning()
            }
        }
    }

    func stillScanning() {
        activityIndicator.startAnimating()
        labelForPassioIDs.text = "Scanning for food"
    }
}

extension PassioQuickStartViewController: PassioStatusDelegate {

    func passioStatusChanged(status: PassioStatus) {
        print("passioRunning = \(passioRunning)")
        if status.mode == .isReadyForDetection, !passioRunning {
            DispatchQueue.main.async {
                self.startFoodDetection()
            }
        }
    }

    func passioProcessing(filesLeft: Int) {
        DispatchQueue.main.async {
            self.labelForPassioIDs.text = "Files left to Process \(filesLeft)"
        }
    }

    func completedDownloadingAllFiles(filesLocalURLs: [FileLocalURL]) {
        DispatchQueue.main.async {
            self.labelForPassioIDs.text = "Completed downloading all files"
        }
    }

    func completedDownloadingFile(fileLocalURL: FileLocalURL, filesLeft: Int) {
        DispatchQueue.main.async {
            self.labelForPassioIDs.text = "Files left to download \(filesLeft)"
        }
    }

    func downloadingError(message: String) {
        print("downloadError   ---- =\(message)")
        DispatchQueue.main.async {
            self.labelForPassioIDs.text = "\(message)"
            self.activityIndicator.stopAnimating()
        }
    }

}
