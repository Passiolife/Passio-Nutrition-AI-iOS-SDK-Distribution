//
//  
//
//  Copyright © 2021 PassioLife Inc All rights reserved.
//

import UIKit
import PassioSDKiOS
import AVFoundation

class LogoViewController: UIViewController {

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    let passioSDK = PassioSDK.shared
    let maxRecentTapView = 5

    var previewLayer: AVCaptureVideoPreviewLayer?
    var logoLabels = [LogoLabel]()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = tabBarItem?.title
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if AVCaptureDevice.authorizationStatus(for: .video) == .authorized { //already authorized
            startLogoDetection()
        } else {
            AVCaptureDevice.requestAccess(for: .video) { (granted) in
                if granted { //access to video granted
                    DispatchQueue.main.async {
                        self.startLogoDetection()
                    }
                } else {
                    print("The user didn't grant access to use camera")
                }
            }
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopLogoDetection()
        previewLayer?.removeFromSuperlayer()
        previewLayer = nil
    }

    func setupPreviewLayer() {
        guard previewLayer == nil else { return }
        if let previewLayer = passioSDK.getPreviewLayer() {
            self.previewLayer = previewLayer
            previewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
            previewLayer.frame = view.bounds
            view.layer.insertSublayer(previewLayer, at: 0)
        }
    }

    @objc func startLogoDetection() {
        activityIndicator.startAnimating()
        setupPreviewLayer()
        let detectionConfig = FoodDetectionConfiguration(framesPerSecond: ., detectLogos: <#T##Bool#>, detectBarcodes: <#T##Bool#>, detectOCR: <#T##Bool#>, nutritionFacts: <#T##Bool#>, sessionPreset: <#T##AVCaptureSession.Preset#>, removeLogoByLogoId: <#T##Bool#>)

        passioSDK.startFoodDetection(detectionConfig: detectionConfig,
                                     foodRecognitionDelegate: self) { (ready) in
            if !ready {
                print("SDK was not configures correctly")
            }
        }
    }

    func stopLogoDetection() {
        passioSDK.stopFoodDetection()
        clearViews()
    }

    func clearViews() {
        logoLabels.forEach { $0.removeFromSuperview() }
        logoLabels = []
    }

}

extension LogoViewController: FoodRecognitionDelegate {

    func recognitionResults(candidates: FoodCandidates?,
                            image: UIImage?,
                            nutritionFacts: PassioNutritionFacts?) {

        DispatchQueue.main.async {
            self.clearViews()
            guard let  logoCandidates = candidates?.logoCandidates, let previewBounds = self.previewLayer?.bounds else {
                self.activityIndicator.startAnimating()
                return
            }
            self.activityIndicator.stopAnimating()
            logoCandidates.forEach {
                let box = $0.boundingBox
                let newBox = self.passioSDK.transformCGRectForm(boundingBox: box, toPreviewLayerRect: previewBounds)
                let center = CGPoint(x: newBox.origin.x + newBox.width/2, y: newBox.origin.y + newBox.height/2  )
                let logoLabel = LogoLabel(candidate: $0, withCenter: center )
                self.logoLabels.append(logoLabel)
                self.view.addSubview(logoLabel)
            }
        }
    }
}
