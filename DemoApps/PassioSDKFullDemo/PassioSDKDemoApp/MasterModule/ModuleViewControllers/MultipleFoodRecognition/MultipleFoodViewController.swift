//
//  MultipeFoodViewController.swift
//  BaseApp
//
//  Created by zvika on 2/19/20.
//  Copyright © 2023 Passio Inc. All rights reserved.
//

import UIKit
#if canImport(PassioNutritionAISDK)
import PassioNutritionAISDK
#endif
import AVFoundation

class MultipleFoodViewController: RotationViewController {

    @IBOutlet weak var trayView: UIView!
    @IBOutlet weak var dashView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var heighOfTrayView: NSLayoutConstraint!
    @IBOutlet weak var buttonClear: UIButton!
    @IBOutlet weak var buttonRecipe: UIButton!
    @IBOutlet weak var buttonAddAll: UIButton!
    @IBOutlet weak var buttonDismiss: UIButton!

    // Common
    let connector = PassioInternalConnector.shared
    let bundlePod = PassioInternalConnector.shared.bundleForModule
    let defaults = UserDefaults.standard
    let confidenceLevel = 0.0

    var foodEditorMiniView: FoodEditorMiniView?
    var nutritionBrowser: NutritionBrowserView?
    // var withLogoDetection = false
    var dismmissToMyLog = false
    var pauseRecognition = false

    // TrayView
    let trayInitialHeight: CGFloat = 200
    let trayViewToViewRatio: CGFloat = 0.8
    var trayAnimator = UIViewPropertyAnimator()

    var imageForFoodRecord: UIImage?
    var lastIndex: Int?

    var model = [FoodRecord]() {
        didSet {
            DispatchQueue.main.async {
                let numberOfFoods = self.model.count
                self.buttonClear.isEnabled = numberOfFoods >  0 ?  true : false
                self.buttonAddAll.isEnabled = numberOfFoods >  0 ?  true : false
                self.buttonRecipe.isEnabled = numberOfFoods >  1 ?  true : false
                self.tableView.reloadWithAnimations(withDuration: 0.1)
            }
        }
    }

    var addedPassioIDs = [PassioID]()

    override func viewDidLoad() {
        super.viewDidLoad()
        volumeDetectionMode = .none
        title = "Meal Builder".localized
        buttonDismiss.setTitle("", for: .normal)
        tableView.delegate = self
        tableView.dataSource = self
        let cell = UINib(nibName: "MultipleTableViewCell", bundle: bundlePod)
        tableView.register(cell, forCellReuseIdentifier: "MultipleTableViewCell")
        buttonClear.isEnabled = false
        buttonRecipe.isEnabled = false
        buttonAddAll.isEnabled = false
        setupTrayView()
    }

    override func startDetection() {
        animateTrayView(isUpwards: false)
        let detectionConfig = FoodDetectionConfiguration(detectVisual: true,
                                                         volumeDetectionMode: volumeDetectionMode,
                                                         detectBarcodes: true,
                                                                         detectPackagedFood: true,
                                                         nutritionFacts: true)
        DispatchQueue.global(qos: .userInitiated).async {
            self.passioSDK.startFoodDetection(detectionConfig: detectionConfig,
                                         foodRecognitionDelegate: self) { (ready) in
                if !ready {
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
    }

    func setupTrayView() {
        let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePan(recognizer:)))
        trayView.addGestureRecognizer(pan)
        dashView.roundMyCorner()
        trayView.roundMyCornerWith(radius: 16)
    }

    @objc func handlePan(recognizer: UIPanGestureRecognizer) {
        let screenHeight = UIScreen.main.bounds.height
        var height = screenHeight - recognizer.location(in: self.view).y + 44
        print("height = \(height) screenHeight = \(screenHeight)")
        if height < trayInitialHeight {
            height = trayInitialHeight
            pauseRecognition = false
        } else if height > screenHeight * trayViewToViewRatio {
            height = screenHeight * trayViewToViewRatio
            pauseRecognition = false
        } else {
            pauseRecognition = false
        }
        switch recognizer.state {
        case .began:
            trayAnimator = UIViewPropertyAnimator(duration: 3, curve: .easeOut, animations: {
                self.view.layoutIfNeeded()
            })
            trayAnimator.startAnimation()
            trayAnimator.pauseAnimation()
        case .changed:
            self.heighOfTrayView.constant = height
            self.view.layoutIfNeeded()
        case .ended:
            trayAnimator.continueAnimation(withTimingParameters: nil, durationFactor: 1)
            self.view.layoutIfNeeded()
        default:
            ()
        }
    }

    func animateTrayView(isUpwards: Bool) {
        let screen = UIScreen.main.bounds
        var trayHeight: CGFloat
        if isUpwards {
            trayHeight = screen.height * trayViewToViewRatio
        } else {
            trayHeight = trayInitialHeight
        }
        let animator = UIViewPropertyAnimator(duration: 0.5, curve: .easeOut, animations: {
            self.heighOfTrayView.constant = trayHeight
            self.view.layoutIfNeeded()
        })
        animator.startAnimation()
    }

    @IBAction func clearAll(_ sender: UIButton? = nil) {
        pauseRecognition = false
        model = []
        addedPassioIDs = []
        animateTrayView(isUpwards: false)
    }

    @IBAction func addRecipe(_ sender: UIButton) {
        guard model.count > 0 else { return }
        pauseRecognition = true
        alertUserForReceipeName()
    }

    func alertUserForReceipeName() {
        let alert = UIAlertController(title: "RecipeNameEdit".localized, message: nil, preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.placeholder = "Name your recipe".localized
            textField.clearButtonMode = .always
        }
        let save = UIAlertAction(title: "Save".localized, style: .default) { (_) in
            let firstTextField = alert.textFields![0] as UITextField
            guard let first = self.model.first else { return }
            var foodRecordRecipe = first
            for index in 1..<self.model.count {
                for ingredient in self.model[index].ingredients {
                    foodRecordRecipe.addIngredient(ingredient: ingredient)
                }
            }
            foodRecordRecipe.name = firstTextField.text ?? "Name your recipe".localized
            self.connector.updateRecord(foodRecord: foodRecordRecipe, isNew: true)
            self.displayAdded(withText: "Recipe added to Log")
            self.clearAll()
            self.animateTrayView(isUpwards: false)
        }
        let cancel = UIAlertAction(title: "Cancel".localized, style: .cancel) { (_) in
        }
        alert.addAction(save)
        alert.addAction(cancel)
        present(alert, animated: true)
    }

    @IBAction func addAll(_ sender: UIButton) {
        model.forEach {
            connector.updateRecord(foodRecord: $0, isNew: true)
        }
        animateTrayView(isUpwards: false)
        var text = model.count > 1 ? "\(model.count) Items" : "Item"
        text += " added to Log"
        displayAdded(withText: text)
        clearAll()
    }

    func addCandidtesToList(passioIDAttributes: PassioIDAttributes,
                            candidate: DetectedCandidate? = nil ) {
        var estimatedWeight: Double? // = candidate?.amountEstimate?.
        if let quality = candidate?.amountEstimate?.estimationQuality,
           quality != .poor {
            estimatedWeight = candidate?.amountEstimate?.weightEstimate
        }
        let foodRecord = FoodRecord(passioIDAttributes: passioIDAttributes,
                                    replaceVisualPassioID: nil,
                                    replaceVisualName: nil,
                                    scannedWeight: estimatedWeight
        )
        addedPassioIDs.append(foodRecord.passioID)
        model.insert(foodRecord, at: 0)
    }

    @IBAction func dismissView(_ sender: UIButton) {
        dismiss(animated: true)
    }

    func displayAdded(withText: String) {
        let width: CGFloat = 200
        let height: CGFloat = 40
        let fromButton: CGFloat = 100
        let frame = CGRect(x: (view.bounds.width - width)/2,
                           y: view.bounds.height - fromButton,
                           width: width,
                           height: height)
        let addedToLog = AddedToLogView(frame: frame, withText: withText)
        view.addSubview(addedToLog)
        addedToLog.removeAfter(withDuration: 1, delay: 1)
    }

}

extension MultipleFoodViewController: FoodRecognitionDelegate {

    func recognitionResults(candidates: FoodCandidates?,
                            // mostSeen: PassioID?,
                            image: UIImage?,
                            nutritionFacts: PassioNutritionFacts?) {
        guard !pauseRecognition else { return }
        imageForFoodRecord = image
        candidates?.detectedCandidates.forEach {
            // print("candidnate = \($0.passioID), amounts =\($0.estimatedVolume), confidence = \($0.confidence) \naddedPassioIDs\(addedPassioIDs)" )
            let confidence = $0.confidence
            let passioID = $0.passioID
            if passioID != "BKG0001",
               confidence > confidenceLevel,
               !self.addedPassioIDs.contains(passioID),
               let pidAtt = passioSDK.lookupPassioIDAttributesFor(passioID: passioID) {
                addCandidtesToList(passioIDAttributes: pidAtt, candidate: $0)
            }
        }

        candidates?.barcodeCandidates?.forEach {
            passioSDK.fetchPassioIDAttributesFor(barcode: $0.value) { (passioIDAttributes) in
                if let pidAtt = passioIDAttributes, !self.addedPassioIDs.contains(pidAtt.passioID) {
                    self.addCandidtesToList(passioIDAttributes: pidAtt)
                }
            }
        }

        // candidates?.packagedFoodCandidates?.forEach {
        if let firstCandidate = candidates?.packagedFoodCandidates?.first {
            passioSDK.fetchPassioIDAttributesFor(packagedFoodCode: firstCandidate.packagedFoodCode) { (pIDAttributes) in
                if let pidAtt = pIDAttributes, !self.addedPassioIDs.contains(pidAtt.passioID) {
                    self.addCandidtesToList(passioIDAttributes: pidAtt)
                }
            }
        }
    }

}

extension MultipleFoodViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let foodRecord = model[indexPath.row]
        animateFoodEditorMiniView(show: true, passioIDAttributes: nil,
                                  foodRecord: foodRecord, grams: nil, fromFrame: nil)
        lastIndex = indexPath.row
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle,
                   forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            model.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }

}

extension MultipleFoodViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        model.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "MultipleTableViewCell",
                                                       for: indexPath) as? MultipleTableViewCell else {
            return UITableViewCell()
        }
        let foodRecord = model[indexPath.row]
        cell.foodName.text = foodRecord.name.capitalized
        // cell.imageFood.image = foodRecord.icon
        cell.passioIDForCell = foodRecord.passioID
        cell.imageFood.loadPassioIconBy(passioID: foodRecord.passioID,
                                        entityType: foodRecord.entityType) { passioIDForImage, image in
            if passioIDForImage == cell.passioIDForCell {
                DispatchQueue.main.async {
                    DispatchQueue.main.async {
                        cell.imageFood.image = image
                    }
                }
            }
        }
        let cancel = "cancel_circle" // foodRecord.isSelected ? ""/*Checkmark_Selected" */: "Checkmark_Unselected"
        let image = UIImage(named: cancel, in: bundlePod, compatibleWith: nil)
        cell.buttonCheckBox.setImage(image, for: .normal)
        cell.buttonCheckBox.tag = indexPath.row
        cell.buttonCheckBox.addTarget(self, action: #selector(selectButtonWasTapped(sender:)), for: .touchUpInside)
        let number = foodRecord.selectedQuantity == Double(Int(foodRecord.selectedQuantity)) ?
            String(Int(foodRecord.selectedQuantity)) : String(foodRecord.selectedQuantity.roundDigits(afterDecimal: 1))
        let amount = number + " \(foodRecord.selectedUnit) " +
            "(\(String(Int(foodRecord.computedWeight.value))) \("Gram".localized))"
        cell.amountLabel.text = amount

        cell.selectionStyle = .none
        return cell
    }

    @objc func selectButtonWasTapped(sender: UIButton) {
        toogleCheckBook(index: sender.tag)
    }

    func toogleCheckBook(index: Int) {
        model.remove(at: index)
        tableView.reloadWithAnimations(withDuration: 0.5)
    }

}

extension MultipleFoodViewController: FoodEditorDelegate {

    func startNutritionBrowser(foodRecord: FoodRecord) {
        animateNutritionBrowserView(show: true, foodRecord: foodRecord)
    }

    func animateMicroTotheLeft() {
    }

    func addFoodToLog(foodRecord: FoodRecord) {
        for (index, record) in model.enumerated() where record.uuid == foodRecord.uuid {
            model[index] = foodRecord
            break
        }
        animateFoodEditorMiniView(show: false)
    }

    func addFoodFavorites(foodRecord: FoodRecord) {
    }

    func foodEditorCancel() {
        animateFoodEditorMiniView(show: false)
    }

    func rescanVolume() {
    }

    func animateFoodEditorMiniView(show: Bool,
                                   passioIDAttributes: PassioIDAttributes? = nil,
                                   foodRecord: FoodRecord? = nil,
                                   grams: Double? = nil,
                                   fromFrame: CGRect? = nil) {
        let screen = UIScreen.main.bounds
        if show, foodEditorMiniView == nil,
            (passioIDAttributes != nil || foodRecord != nil) {
            var foundFoodRecord = foodRecord

            if foundFoodRecord == nil, let pAtt = passioIDAttributes {
                foundFoodRecord = FoodRecord(passioIDAttributes: pAtt,
                                             replaceVisualPassioID: nil,
                                             replaceVisualName: nil)
            }

            guard var newFoodRecord = foundFoodRecord else {
                return
            }

            if let grams = grams,
               newFoodRecord.setFoodRecordServing(unit: "gram", quantity: grams),
               newFoodRecord.setSelectedUnitKeepWeight(unitName: "gram") {
                print("Amount changed sessefully")
            }
            // frames
            let margin: CGFloat = 10.0
            var frameStarting: CGRect
            if let loc = fromFrame {
                frameStarting = loc
            } else {
                frameStarting = CGRect(x: screen.width/2, y: screen.height/2, width: 0, height: 0)
            }
            var height: CGFloat
            if let alt = newFoodRecord.alternativesPassioID, !alt.isEmpty {
                height = 480
            } else {
                height = 380
            }
            let frameFinal = CGRect(x: margin, y: screen.height/2-height/2 + 44,
                                    width: screen.width-2*margin, height: height)
            // Food EditorView
            let nib = UINib(nibName: "FoodEditorMiniView", bundle: bundlePod)
            foodEditorMiniView = nib.instantiate(withOwner: self, options: nil).first as? FoodEditorMiniView
            foodEditorMiniView?.foodRecord = newFoodRecord
            foodEditorMiniView?.isMiniEditorInMultipleFood = true
            foodEditorMiniView?.showAmount = true
            foodEditorMiniView?.delegate = self
            foodEditorMiniView?.frame = frameStarting
            foodEditorMiniView?.roundMyCornerWith(radius: 20)
            view.addSubview(foodEditorMiniView!)
            // unique **********
            //  isRecognitionsPaused = false
            foodEditorMiniView?.buttonSave.setTitle("Save".localized, for: .normal)
            foodEditorMiniView?.favoriteButtonIsAlwaysHidden = true
            foodEditorMiniView?.saveToConnector = false
            UIView.animateKeyframes(withDuration: 0.5, delay: 0, options: .calculationModeCubic, animations: {
                self.foodEditorMiniView?.frame = frameFinal
                self.trayView.isHidden = true
            })
        } else {
            guard let currentFrame = foodEditorMiniView?.frame else { return }
            let frameFinal = CGRect(x: currentFrame.origin.x, y: screen.height,
                                    width: currentFrame.width, height: currentFrame.height)
            UIView.animateKeyframes(withDuration: 0.5, delay: 0, options: .calculationModeCubic, animations: {
                self.foodEditorMiniView?.frame = frameFinal
                self.trayView.isHidden = false
            }, completion: { _ in

                if let lastIndex = self.lastIndex,
                   let foodRecord = self.foodEditorMiniView?.foodRecord {
                    self.model[lastIndex] = foodRecord
                }
                self.foodEditorMiniView?.removeFromSuperview()
                self.foodEditorMiniView = nil
                // self.animateFoodEditorMicroView(show: false)
            })
        }
    }
}

extension MultipleFoodViewController { // Nutrition Browser

    func animateNutritionBrowserView(show: Bool, passioIDAttributes: PassioIDAttributes? = nil,
                                     foodRecord: FoodRecord? = nil, fromFrame: CGRect? = nil) {
        if show, (passioIDAttributes != nil || foodRecord != nil) {

            let marginWidth: CGFloat = 10.0
            let marginHeight: CGFloat = 100
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
            nutritionBrowser = nib.instantiate(withOwner: self, options: nil).first as? NutritionBrowserView
            guard let nutritionBrowser = nutritionBrowser else {
                return
            }
            nutritionBrowser.foodRecord = newFoodRecord
            nutritionBrowser.frame = frameStarting
            nutritionBrowser.roundMyCornerWith(radius: 20)
            nutritionBrowser.delegate = self
            view.addSubview(nutritionBrowser)

            UIView.animateKeyframes(withDuration: 0.5, delay: 0, options: .calculationModeCubic, animations: {
                nutritionBrowser.frame = frameFinal

            })
        } else {
            guard let currentFrame = nutritionBrowser?.frame else { return }
            let frameFinal = CGRect(x: currentFrame.origin.x, y: view.bounds.height,
                                    width: currentFrame.width, height: currentFrame.height)
            UIView.animateKeyframes(withDuration: 0.5, delay: 0, options: .calculationModeCubic, animations: {
                self.nutritionBrowser?.frame = frameFinal
            }, completion: { _ in
                self.nutritionBrowser?.removeFromSuperview()
                self.nutritionBrowser = nil
                if let foodRecord = foodRecord {
                    self.foodEditorMiniView?.foodRecord = foodRecord
                }
            })
        }
    }
}

extension MultipleFoodViewController: NutritionBrowserDelegate {

    func userSelectedFromNBrower(foodRecord: FoodRecord?) {
        animateNutritionBrowserView(show: false, foodRecord: foodRecord)
    }

    func userCancelledNBrowser(originalRecord: FoodRecord?) {
        animateNutritionBrowserView(show: false, foodRecord: originalRecord)
    }

}
