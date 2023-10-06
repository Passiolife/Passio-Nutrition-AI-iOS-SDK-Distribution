//
//  FoodRecognitionViewController.swift
//  BaseApp
//
//  Created by zvika on 1/21/20.
//  Copyright © 2023 Passio Inc. All rights reserved.
//

import UIKit
import AVFoundation
#if canImport(PassioNutritionAISDK)
import PassioNutritionAISDK
#endif

class FoodRecognitionViewController: RotationViewController {

    @IBOutlet weak var buttonContinueScanning: UIButton!
    @IBOutlet weak var activeIndicator: UIActivityIndicatorView!
    @IBOutlet weak var buttonDismiss: UIButton!
    // Common
    let connector = PassioInternalConnector.shared
    let bundlePod = PassioInternalConnector.shared.bundleForModule
    let defaults = UserDefaults.standard

    var foodEditorMiniView: FoodEditorMiniView?
    var nutritionBrowserView: NutritionBrowserView?
    var dismmissToMyLog = false
    var lastDetectedCandidates: [DetectedCandidate] = []
    var scanneWeightToDisplay: Double? {
        didSet {
            if scanneWeightToDisplay == nil {
                lastDetectedCandidates.removeAll()
            }
        }
    }

    // On top views
    let marginWidth: CGFloat = 10.0
    let marginHeight: CGFloat = 100
    let toSaveToAlbum = false

    // Pause Recognitions
    var isRecognitionsPaused = false {
        didSet {
            lastPackagedFoodDetection = nil
            packageFoodPassioIDAttributes = nil
        }
    }

    // FoodEditorMicroView.
    var foodEditorMicroView: FoodEditorMicroView? {
        didSet {
            if foodEditorMicroView != nil {
                activeIndicator.stopAnimating()
            }
        }
    }

    var isFoodEditorMicroDisplayed: Bool {
        foodEditorMicroView == nil ? false : true
    }
    var isMicroEditorPaused = false {
        didSet {
            videoLayer?.opacity = isMicroEditorPaused ? 0.3 : 1
            buttonContinueScanning.isHidden = !isMicroEditorPaused
            isRecognitionsPaused = isMicroEditorPaused
        }
    }
    // FoodEditorMiniView.
    var isFoodEditorMiniDisplayed: Bool {
        foodEditorMiniView == nil ? false : true
    }

    // Nutrition Facts
    var nutritionFactsConstructor: PassioNutritionFacts?
    var isNutritionFactsDisplayed: Bool {
        nutritionFactsView == nil ? false : true
    }

    var nutritionFactsView: NutritionFactsView?
    var isNutritionBrowserDisplayed: Bool {
        nutritionBrowserView == nil ? false : true
    }
    // Timers
    var lastObjectDetection: Date?
    // var timeToDisplayResult = 0.4 // configure
    // Barcode
    let timeToDisplayBarCodeResults = 2.0
    var barcodeAttributes: PassioIDAttributes?
    var lastBarcodeDetection: Date?
    // PackgedFood
    let timeToDisplayPackagedFoodResults = 2.0
    var packageFoodPassioIDAttributes: PassioIDAttributes?
    var lastPackagedFoodDetection: Date?

    var imageForFoodRecord: UIImage? {
        didSet {
            lastObjectDetection = Date()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        buttonContinueScanning.setTitle("", for: .normal)
        buttonDismiss.setTitle("", for: .normal)
        view.backgroundColor = UIColor(named: "PassioBackgroundWhite",
                                       in: bundlePod, compatibleWith: nil)
        if connector.isInNavController {
            title = "Passio Nutrition-AI".localized
            // title = "\(passioSDK.status.architecture)"
            customizeNavForModule()
            navigationItem.leftBarButtonItem = nil
            navigationController?.navigationBar.barStyle = .default
        }
        NotificationCenter.default.addObserver(self, selector: #selector(checkSpinner),
                                               name: UIApplication.willEnterForegroundNotification, object: nil)

#if canImport(FirebaseAnaltytics)
        passioFirebaseAnalytics = PassioFirebaseAnalytics()
#endif
    }

    @objc func checkSpinner() {
        if isFoodEditorMicroDisplayed {
            animateFoodEditorMicroView(show: false)
        }
    }

    @objc func dismissPassioAppModule() {
        navigationController?.popViewController(animated: true)
    }

    override func startDetection() {
        isRecognitionsPaused = false
        let detectionConfig = FoodDetectionConfiguration(detectVisual: true,
                                                         volumeDetectionMode: volumeDetectionMode,
                                                         detectBarcodes: true,
                                                         detectPackagedFood: true,
                                                         nutritionFacts: true)
        DispatchQueue.global(qos: .userInitiated).async {
            self.passioSDK.startFoodDetection(detectionConfig: detectionConfig,
                                         foodRecognitionDelegate: self) { (ready) in
                if  !ready {
                    print("SDK was not configured correctly")
                }
                DispatchQueue.main.async {
                    self.view.bringSubviewToFront(self.buttonDismiss)
                }
            }
        }

    }

    override func stopDetection() {
        passioSDK.stopFoodDetection()
        animateFoodEditorMicroView(show: false)
        isRecognitionsPaused = true
        if isFoodEditorMicroDisplayed { animateFoodEditorMicroView(show: false) }
        if isFoodEditorMiniDisplayed { animateFoodEditorMiniView(show: false, fromFrame: nil) }
        if isNutritionFactsDisplayed { animateNutritionFactView(show: false) }
        if isNutritionBrowserDisplayed { animateNutritionBrowserView(show: false) }
    }

    @IBAction func pressPlay(_ sender: UIButton) {
        isMicroEditorPaused = false
        animateFoodEditorMicroView(show: true)
    }

    @IBAction func dismissView(_ sender: UIButton) {
        dismiss(animated: true)
    }

}

extension FoodRecognitionViewController: FoodRecognitionDelegate {

    func recognitionResults(candidates: FoodCandidates?,
                            image: UIImage?,
                            nutritionFacts: PassioNutritionFacts?) {
        guard !isRecognitionsPaused,
              videoLayer != nil else {
                  return
              }

        if toSaveToAlbum, let image = image {
            UIImageWriteToSavedPhotosAlbum(image, self, nil, nil)
        }

        // nutritionFacts
        if !isFoodEditorMiniDisplayed,
           !isNutritionBrowserDisplayed,
           let nutritionFacts = nutritionFacts,
           nutritionFacts.foundNutritionFactsLabel {
            self.nutritionFactsConstructor = nutritionFacts
            DispatchQueue.main.async {
                if let nfView = self.nutritionFactsView {
                    nfView.reloadNFCView()
                } else {
                    self.animateNutritionFactView(show: true, nutritionFactsConstructor: self.nutritionFactsConstructor)
                }
            }
            return
        }

        guard !isFoodEditorMiniDisplayed, !isNutritionFactsDisplayed, !isNutritionBrowserDisplayed else {
            DispatchQueue.main.async {
                self.animateFoodEditorMicroView(show: false, passioIDAttributes: nil)
            }
            return
        }

        // Barcode
        if let time = lastBarcodeDetection,
           Date().timeIntervalSince(time) < timeToDisplayBarCodeResults {
            return
        } else if let barcode = candidates?.barcodeCandidates?.first {
            lastBarcodeDetection = Date()
            passioSDK.fetchPassioIDAttributesFor(barcode: barcode.value) { (passioIDAttributes) in
                if let pidAtt = passioIDAttributes {
                    self.barcodeAttributes = passioIDAttributes
                    DispatchQueue.main.async {
                        self.animateFoodEditorMicroView(show: true, passioIDAttributes: pidAtt)
                    }
                }
            }
        } else {
            lastBarcodeDetection = nil
            barcodeAttributes = nil
        }
        guard barcodeAttributes == nil else { return  }

        // PackagedFood
        if let time = lastPackagedFoodDetection,
           Date().timeIntervalSince(time) < timeToDisplayPackagedFoodResults {
            return
        } else if let candidate = candidates?.packagedFoodCandidates?.first {
            lastPackagedFoodDetection = Date()
            passioSDK.fetchPassioIDAttributesFor(packagedFoodCode: candidate.packagedFoodCode) { (pIDAttributes) in
                if let pidAtt = pIDAttributes {
                    self.packageFoodPassioIDAttributes = pIDAttributes
                    if !self.isRecognitionsPaused {
                        DispatchQueue.main.async {
                            self.animateFoodEditorMicroView(show: true, passioIDAttributes: pidAtt)
                        }
                    }
                }
            }
        } else {
            lastPackagedFoodDetection = nil
            packageFoodPassioIDAttributes = nil
        }

        guard packageFoodPassioIDAttributes == nil else { return }
        imageForFoodRecord = image

        var foodRecord: FoodRecord?
        if let firstCandidate = candidates?.detectedCandidates.first,
           firstCandidate.passioID != "BKG0001" {
            if let pAtt = passioSDK.lookupPassioIDAttributesFor(passioID: firstCandidate.passioID) {
                var estimatedWeight: Double?
                if let quality = firstCandidate.amountEstimate?.estimationQuality,
                   quality == .good {
                    estimatedWeight = firstCandidate.amountEstimate?.weightEstimate
                }
                foodRecord = FoodRecord(passioIDAttributes: pAtt,
                                        replaceVisualPassioID: pAtt.passioID,
                                        replaceVisualName: pAtt.name,
                                        scannedWeight: estimatedWeight)
            }

        }
        DispatchQueue.main.async {
            if foodRecord == nil {
                self.scanneWeightToDisplay = nil
            }
            self.animateFoodEditorMicroView(show: true, foodRecord: foodRecord)
        }
    }
}

extension FoodRecognitionViewController {

    func animateNutritionFactView(show: Bool, nutritionFactsConstructor: PassioNutritionFacts? = nil,
                                  animated: Bool = false, foodName: String? = nil) {
        if show, nutritionFactsView == nil {
            let nib = UINib(nibName: "NutritionFactsView", bundle: bundlePod)
            nutritionFactsView = nib.instantiate(withOwner: self, options: nil).first as? NutritionFactsView
            let frameStarting = CGRect(x: view.bounds.width/2, y: view.bounds.height/2, width: 0, height: 0)
            let height: CGFloat = 380
            let yOrigin = view.bounds.height - height - marginHeight + connector.offsetFoodEditor
            let frameFinal = CGRect(x: marginWidth,
                                    y: yOrigin,
                                    width: view.bounds.width - 2 * marginWidth,
                                    height: height)
            nutritionFactsView?.frame = frameStarting
            nutritionFactsView?.nfc = nutritionFactsConstructor
            nutritionFactsView?.roundMyCornerWith(radius: 20)
            nutritionFactsView?.delegate = self
            view.addSubview(nutritionFactsView!)
            UIView.animateKeyframes(withDuration: 0.5, delay: 0, options: .calculationModeCubic, animations: {
                self.nutritionFactsView?.frame = frameFinal
            }) { (_) in
                self.animateFoodEditorMicroView(show: false)
                self.nutritionFactsView?.reloadNFCView()
            }
        } else if !show {
            guard let currentFrame = nutritionFactsView?.frame else { return }
            let frameFinal = CGRect(x: currentFrame.origin.x, y: view.bounds.height,
                                    width: currentFrame.width, height: currentFrame.height)
            UIView.animateKeyframes(withDuration: 0.5, delay: 0, options: .calculationModeCubic, animations: {
                self.nutritionFactsView?.frame = frameFinal
            }, completion: { _ in
                self.nutritionFactsView = nil
                if let name = foodName {
                    let pidAtt = self.nutritionFactsConstructor?.createPassioIDAttributes(foodName: name)
                    self.animateFoodEditorMiniView(show: true, passioIDAttributes: pidAtt, fromFrame: nil)
                } else {
                    self.animateFoodEditorMicroView(show: false)
                }
                self.nutritionFactsConstructor?.clearAll()
            })
        }
    }

}

extension FoodRecognitionViewController: NutritionFactsViewDelegate {

    func userPressedNext(withName name: String) {
        animateNutritionFactView(show: false, animated: true, foodName: name)
    }

    func userCancelNutritionFacts() {
        animateNutritionFactView(show: false)
    }

}

extension FoodRecognitionViewController { // Animations

    func animateFoodEditorMicroView(show: Bool,
                                    passioIDAttributes: PassioIDAttributes? = nil,
                                    foodRecord: FoodRecord? = nil) {

        if show {
            var newFoodRecord = foodRecord
            if let pidAtt = passioIDAttributes, newFoodRecord == nil {
                newFoodRecord = FoodRecord(passioIDAttributes: pidAtt,
                                           replaceVisualPassioID: nil,
                                           replaceVisualName: nil)
            }
            let editorHeight: CGFloat = 144
            let yOrigin = view.bounds.height - editorHeight - marginHeight + connector.offsetFoodEditor
            let frameFinal = CGRect(x: marginWidth,
                                    y: yOrigin,
                                    width: view.bounds.width - 2 * marginWidth,
                                    height: editorHeight)
            if foodEditorMicroView == nil {
                let nib = UINib(nibName: "FoodEditorMicroView", bundle: bundlePod)
                foodEditorMicroView = nib.instantiate(withOwner: self, options: nil).first as? FoodEditorMicroView
                foodEditorMicroView?.delegate = self
                foodEditorMicroView?.roundMyCornerWith(radius: 20)
                foodEditorMicroView?.frame = frameFinal
                foodEditorMicroView?.isMicroAlternatives = true
                if let foodEditorMicroView = foodEditorMicroView {
                    view.addSubview(foodEditorMicroView)
                }
                UIView.animateKeyframes(withDuration: 0.2, delay: 0, options: .calculationModeCubic, animations: {
                    self.foodEditorMicroView?.frame = frameFinal
                })
            }
            if newFoodRecord != foodEditorMicroView?.foodRecord {
                foodEditorMicroView?.foodRecord = newFoodRecord
            }
        } else { // remove view
            UIView.animateKeyframes(withDuration: 0.2, delay: 0, options: .calculationModeCubic, animations: {
                self.foodEditorMicroView?.alpha = 0
            }, completion: { _ in
                self.foodEditorMicroView?.removeFromSuperview()
                self.foodEditorMicroView = nil
            })
        }

    }

    func animateFoodEditorMiniView(show: Bool,
                                   passioIDAttributes: PassioIDAttributes? = nil,
                                   foodRecord: FoodRecord? = nil,
                                   grams: Double? = nil,
                                   fromFrame: CGRect? = nil,
                                   animateNutritionBrowser: Bool = false) {
        // print("foodEditorMiniView?.bounds = \(foodEditorMiniView?.bounds)")
        scanneWeightToDisplay = nil
        if show, foodEditorMiniView == nil, (passioIDAttributes != nil || foodRecord != nil) {
            // FoodRecord
            var foundFoodRecord = foodRecord

            if foundFoodRecord == nil, let pAtt = passioIDAttributes {
                foundFoodRecord = FoodRecord(passioIDAttributes: pAtt, replaceVisualPassioID: nil, replaceVisualName: nil)
            }

            guard var newFoodRecord = foundFoodRecord else {
                return
            }

            if let grams = grams,
               newFoodRecord.setFoodRecordServing(unit: "gram", quantity: grams),
               newFoodRecord.setSelectedUnitKeepWeight(unitName: "gram") {
                // print("Amount changed sessefully")
            }
            // frames
            var frameStarting: CGRect
            if let loc = fromFrame {
                frameStarting = loc
            } else {
                frameStarting = CGRect(x: view.bounds.width/2, y: view.bounds.height/2, width: 0, height: 0)
            }
            var editorHeight: CGFloat

            let heightForOpenFood: CGFloat = newFoodRecord.isOpenFood ? 60 : 0
            if let alt = newFoodRecord.alternativesPassioID, !alt.isEmpty {
                editorHeight = 567 + heightForOpenFood// 567 //480
            } else {
                editorHeight = 476 + heightForOpenFood// 467 //380
            }

            let yOrigin = view.bounds.height - editorHeight - marginHeight + connector.offsetFoodEditor

            let frameFinal = CGRect(x: marginWidth,
                                    y: yOrigin,
                                    width: view.bounds.width - 2 * marginWidth,
                                    height: editorHeight)
            // Food EditorView
            let nib = UINib(nibName: "FoodEditorMiniView", bundle: bundlePod)
            foodEditorMiniView = nib.instantiate(withOwner: self, options: nil).first as? FoodEditorMiniView
            foodEditorMiniView?.foodRecord = newFoodRecord
            foodEditorMiniView?.isMiniEditor = true
            foodEditorMiniView?.showAmount = true
            foodEditorMiniView?.delegate = self
            foodEditorMiniView?.frame = frameStarting
            foodEditorMiniView?.roundMyCornerWith(radius: 20)
            view.addSubview(foodEditorMiniView!)
            // unique **********
            isRecognitionsPaused = true

            foodEditorMicroView?.removeFromSuperview()
            foodEditorMicroView = nil
            UIView.animateKeyframes(withDuration: 0.5, delay: 0, options: .calculationModeCubic, animations: {
                self.foodEditorMiniView?.frame = frameFinal
            })
        } else {
            guard let currentFrame = foodEditorMiniView?.frame else { return }

            var foodForNutritionBowser: FoodRecord?

            if animateNutritionBrowser {
                foodForNutritionBowser = foodEditorMiniView?.foodRecord
            }

            let frameFinal = CGRect(x: currentFrame.origin.x, y: view.bounds.height,
                                    width: currentFrame.width, height: currentFrame.height)
            UIView.animateKeyframes(withDuration: 0.5, delay: 0, options: .calculationModeCubic, animations: {
                self.foodEditorMiniView?.frame = frameFinal
            }, completion: { _ in
                self.foodEditorMiniView?.removeFromSuperview()
                self.foodEditorMiniView = nil
                if animateNutritionBrowser, let foodRecord = foodForNutritionBowser {
                    self.animateNutritionBrowserView(show: true, foodRecord: foodRecord)
                } else {
                    self.isMicroEditorPaused = false
                }
                self.isRecognitionsPaused = false
                // self.animateFoodEditorMicroView(show: false)
            })
        }
    }

    func animateFoodViewToTheRight() {
        guard let foodEditorMicro = foodEditorMicroView else { return }
        self.isRecognitionsPaused = true
        let screenSize = UIScreen.main.bounds.size
        UIView.animateKeyframes(withDuration: 1, delay: 0, options: [.calculationModeLinear], animations: {
            foodEditorMicro.center = CGPoint(x: screenSize.width * 2, y: foodEditorMicro.center.y)
            self.buttonContinueScanning.isEnabled = false
        }) { (_) in
            // self.setFoodView(isHidden: false)
            self.buttonContinueScanning.isEnabled = true
            self.foodEditorMicroView = nil
            self.isRecognitionsPaused = false
            self.isMicroEditorPaused = false
        }
    }

    func animateCleaningPersonalizations() {
        guard let foodEditorMicro = foodEditorMicroView else { return }
        self.isRecognitionsPaused = true
        let screenSize = UIScreen.main.bounds.size
        UIView.animateKeyframes(withDuration: 1, delay: 0, options: [.calculationModeLinear], animations: {
            foodEditorMicro.center = CGPoint(x: -(screenSize.width * 2), y: foodEditorMicro.center.y)
            self.buttonContinueScanning.isEnabled = false
        }) { (_) in
            // self.setFoodView(isHidden: false)
            self.buttonContinueScanning.isEnabled = true
            self.foodEditorMicroView = nil
            self.isRecognitionsPaused = false
            self.isMicroEditorPaused = false
        }
    }

}

extension FoodRecognitionViewController: FoodEditorDelegate {

    func startNutritionBrowser(foodRecord: FoodRecord) {
        if foodEditorMicroView == nil {
            animateFoodEditorMiniView(show: false, animateNutritionBrowser: true)
        } else {
            animateNutritionBrowserView(show: true, foodRecord: foodRecord)
        }
    }

    func animateMicroTotheLeft() {
        animateCleaningPersonalizations()
    }

    func addFoodToLog(foodRecord: FoodRecord) {
        if foodEditorMicroView != nil {
            animateFoodViewToTheRight()
        } else if foodEditorMiniView != nil {
            animateFoodEditorMiniView(show: false)
        }
        displayAdded()
    }

    func displayAdded() {
        let width: CGFloat = 200
        let height: CGFloat = 40
        let fromButton: CGFloat = 100
        let frame = CGRect(x: (view.bounds.width - width)/2,
                           y: view.bounds.height - fromButton,
                           width: width,
                           height: height)
        let addedToLog = AddedToLogView(frame: frame, withText: "Item added to log")
        view.addSubview(addedToLog)
        addedToLog.removeAfter(withDuration: 1, delay: 1)
    }

    func foodEditorRequest(pauseRecognition: Bool) {
        isMicroEditorPaused = pauseRecognition
    }

    func foodEditorCancel() {
        animateFoodEditorMiniView(show: false, fromFrame: nil)
    }

    func addFoodFavorites(foodRecord: FoodRecord) {
        connector.updateFavorite(foodRecord: foodRecord)
    }

    func userSelected(foodRecord: FoodRecord) {
        animateFoodEditorMiniView(show: true, foodRecord: foodRecord)
    }

    func rescanVolume() {
        scanneWeightToDisplay = nil
        animateFoodEditorMicroView(show: true, foodRecord: nil)
    }

}

extension FoodRecognitionViewController: UIAdaptivePresentationControllerDelegate {

    func presentationControllerShouldDismiss(_ presentationController: UIPresentationController) -> Bool {
        isRecognitionsPaused = false
        return true
    }

}

extension FoodRecognitionViewController { // Nutrition Browser

    func animateNutritionBrowserView(show: Bool,
                                     passioIDAttributes: PassioIDAttributes? = nil,
                                     foodRecord: FoodRecord? = nil,
                                     fromFrame: CGRect? = nil) {
        if show, (passioIDAttributes != nil || foodRecord != nil) {
            // FoodRecord
            var foundFoodRecord = foodRecord

            if foundFoodRecord == nil, let pAtt = passioIDAttributes {
                foundFoodRecord = FoodRecord(passioIDAttributes: pAtt, replaceVisualPassioID: nil, replaceVisualName: nil)
            }

            guard let newFoodRecord = foundFoodRecord,
                  (newFoodRecord.entityType == .group ||
                   newFoodRecord.entityType == .item ||
                   newFoodRecord.entityType == .recipe ||
                   newFoodRecord.entityType == .barcode ||
                   newFoodRecord.entityType == .packagedFoodCode) else {
                      return
                  }

            isRecognitionsPaused = true
            isMicroEditorPaused = true

            // frames

            var frameStarting: CGRect
            if let loc = fromFrame {
                frameStarting = loc
            } else {
                frameStarting = CGRect(x: view.bounds.width/2, y: view.bounds.height/2, width: 0, height: 0)
            }
            let editorHeight: CGFloat = view.bounds.height * 0.7

            let yOrigin = view.bounds.height - editorHeight - marginHeight + connector.offsetFoodEditor

            let frameFinal = CGRect(x: marginWidth,
                                    y: yOrigin,
                                    width: view.bounds.width - 2 * marginWidth,
                                    height: editorHeight)
            // Food EditorView
            let nib = UINib(nibName: "NutritionBrowserView", bundle: bundlePod)
            nutritionBrowserView = nib.instantiate(withOwner: self, options: nil).first as? NutritionBrowserView
            guard let nutritionBrowser = nutritionBrowserView else {
                return
            }
            nutritionBrowser.foodRecord = newFoodRecord
            nutritionBrowser.frame = frameStarting
            nutritionBrowser.roundMyCornerWith(radius: 20)
            nutritionBrowser.delegate = self
            view.addSubview(nutritionBrowser)
            isRecognitionsPaused = true
            isMicroEditorPaused = true
            foodEditorMicroView?.removeFromSuperview()
            foodEditorMicroView = nil
            UIView.animateKeyframes(withDuration: 0.5, delay: 0, options: .calculationModeCubic, animations: {
                nutritionBrowser.frame = frameFinal
            })
        } else {
            guard let currentFrame = nutritionBrowserView?.frame else { return }
            let frameFinal = CGRect(x: currentFrame.origin.x, y: view.bounds.height,
                                    width: currentFrame.width, height: currentFrame.height)
            UIView.animateKeyframes(withDuration: 0.5, delay: 0, options: .calculationModeCubic, animations: {
                self.nutritionBrowserView?.frame = frameFinal
            }, completion: { _ in
                self.nutritionBrowserView?.removeFromSuperview()
                self.nutritionBrowserView = nil
                if let foodRecord = foodRecord {
                    self.foodEditorMiniView?.removeFromSuperview()
                    self.foodEditorMicroView = nil
                    self.animateFoodEditorMiniView(show: true, foodRecord: foodRecord)
                } else {
                    self.isMicroEditorPaused = false
                }
            })
        }
    }
}

extension FoodRecognitionViewController: NutritionBrowserDelegate {

    func userSelectedFromNBrower(foodRecord: FoodRecord?) {
        animateNutritionBrowserView(show: false, foodRecord: foodRecord)
    }

    func userCancelledNBrowser(originalRecord: FoodRecord?) {
        animateNutritionBrowserView(show: false, foodRecord: originalRecord)
    }

}
