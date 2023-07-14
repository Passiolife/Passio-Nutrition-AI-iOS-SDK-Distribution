//
//  ODwithRecentViewController
//
//  Copyright © 2023 PassioLife Inc All rights reserved.
//

import UIKit
import PassioNutritionAISDK
import AVFoundation

class TrackingViewController: UIViewController {

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    let passioSDK = PassioNutritionAI.shared
    let maxRecentTapView = 5

    var videoLayer: AVCaptureVideoPreviewLayer?
    var foodLabels = [FoodLabel]()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = tabBarItem?.title
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if AVCaptureDevice.authorizationStatus(for: .video) == .authorized { // already authorized
            startObjectDetectionWithVotingLayer()
        } else {
            AVCaptureDevice.requestAccess(for: .video) { (granted) in
                if granted { // access to video granted
                    DispatchQueue.main.async {
                        self.startObjectDetectionWithVotingLayer()
                    }
                } else {
                    print("The user didn't grant access to use camera")
                }
            }
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopFoodDetection()
        videoLayer?.removeFromSuperlayer()
        videoLayer = nil
    }

    func setupPreviewLayer() {
        guard videoLayer == nil else { return }
        if let videoLayer = passioSDK.getPreviewLayer() {
            self.videoLayer = videoLayer
            videoLayer.frame = view.bounds
            view.layer.insertSublayer(videoLayer, at: 0)
        }
    }

    @objc func startObjectDetectionWithVotingLayer() {
        activityIndicator.startAnimating()
        setupPreviewLayer()
        var detectionConfig = FoodDetectionConfiguration()
        detectionConfig.detectPackagedFood = true
        detectionConfig.detectBarcodes = true
        DispatchQueue.global(qos: .userInitiated).async {
            self.passioSDK.startFoodDetection(detectionConfig: detectionConfig,
                                         foodRecognitionDelegate: self) { (ready) in
                if !ready {
                    print("SDK was not configured correctly")
                }
            }
        }

    }

    func stopFoodDetection() {
        passioSDK.stopFoodDetection()
        clearViews()
    }

    func clearViews() {
        foodLabels.forEach { $0.removeFromSuperview() }
        foodLabels = []
    }

}

extension TrackingViewController: FoodRecognitionDelegate {

    func recognitionResults(candidates: FoodCandidates?,
                            image: UIImage?,
                            nutritionFacts: PassioNutritionFacts?) {
        DispatchQueue.main.async {
            self.clearViews()
            guard let detetedCandidates = candidates?.detectedCandidates,
                  let previewBounds = self.videoLayer?.bounds else {
                self.activityIndicator.startAnimating()
                return
            }
            self.activityIndicator.stopAnimating()
            detetedCandidates.forEach {
                let box = $0.boundingBox
                let newBox = self.passioSDK.transformCGRectForm(boundingBox: box, toRect: previewBounds)
                let center = CGPoint(x: newBox.origin.x + newBox.width/2, y: newBox.origin.y + newBox.height/2  )
                let foodView = FoodLabel(candidate: $0, withCenter: center )
                self.foodLabels.append(foodView)
                self.view.addSubview(foodView)
            }
        }
    }

}
