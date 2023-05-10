//
//  FoodEditorLegacyView
//  PassioPassport
//
//  Created by zvika on 3/25/19.
//  Copyright © 2023 Passiolife Inc. All rights reserved.
//

import UIKit
#if canImport(PassioNutritionAISDK)
import PassioNutritionAISDK
#endif

protocol IngredientEditorViewDelegate: AnyObject {
    func ingredientEditedFoodItemData( foodItemData: PassioFoodItemData, atIndex: Int)
    func ingredientEditedCancel()
    func startNutritionBrowser(foodItemData: PassioFoodItemData)
}

class IngredientEditorView: UIView {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var buttonCancel: UIButton!
    @IBOutlet weak var buttonSave: UIButton!

    let passioSDK = PassioNutritionAI.shared
    let connector = PassioInternalConnector.shared
    let bundlePod = PassioInternalConnector.shared.bundleForModule

    var indexOfIngredient = 0

    var foodItemData: PassioFoodItemData? {
        didSet {
            UIView.transition(with: tableView, duration: 0.1,
                              options: [.transitionCrossDissolve, .allowUserInteraction],
                              animations: {
                self.tableView.reloadData()
            })
        }
    }

    var alternatives: [PassioAlternative]? {
        guard let foodItemData = foodItemData else {
            return nil
        }
        let tempAlternatives = (foodItemData.parents ?? []) +
        (foodItemData.children ?? []) +
        (foodItemData.siblings ?? [])

        return tempAlternatives.isEmpty ? nil : tempAlternatives
    }

    weak var delegate: IngredientEditorViewDelegate?

    var cachedMaxForSlider = [Int: [String: Float]]()

    override func awakeFromNib() {
        super.awakeFromNib()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.allowsSelection = true
        CellNameFoodEditor.allCases.forEach {
            let cellName = $0.rawValue.capitalizingFirst()
            let cell = UINib(nibName: cellName, bundle: bundlePod)
            tableView.register(cell, forCellReuseIdentifier: cellName)
        }
        //        let image = UIImage(named: "bttn_bg",
        //                            in: bundlePod,
        //                            compatibleWith: nil)
        //        buttonSave.setBackgroundImage(image, for: .normal)
        //        buttonCancel.setBackgroundImage(image, for: .normal)
        buttonCancel.setTitle( "Cancel", for: .normal)
        buttonSave.setTitle( "Save", for: .normal)
        buttonCancel.roundMyCornerWith(radius: Custom.buttonCornerRadius)
        buttonSave.roundMyCornerWith(radius: Custom.buttonCornerRadius)
    }

    // MARK: Button Actions.
    @objc func changeLabel(sender: UIButton ) {
        guard let amount = foodItemData?.servingUnits else { return }
        guard let unitPickerView = Bundle.main.loadNibNamed("UnitPickerView", owner: nil,
                                                            options: nil)?.first as? UnitPickerView else {
            return
        }
        let widthForPicker = bounds.width - 40.0
        let heightForPicker: CGFloat = 240.0
        let convertHeight = sender.convert(sender.frame.origin, to: self)
        unitPickerView.frame = CGRect(x: 20.0, y: convertHeight.y - heightForPicker/2,
                                      width: widthForPicker, height: heightForPicker)
        unitPickerView.labelsForPicker = amount.map { return $0.unitName }
        //   unitPickerView.labelsForPicker = foodRecord?.amountQuickOptions.map {return $0.label}
        // model.getAmoutsLabelsForCell(tableRowOrCollectionTag: sender.tag)
        unitPickerView.tag = sender.tag
        unitPickerView.indexForSelectedUnit = 2
        unitPickerView.delegate = self
        addSubview(unitPickerView)
    }

    @IBAction func saveIngredient(_ sender: UIButton) {
        if let  foodItemData = foodItemData {
            delegate?.ingredientEditedFoodItemData(foodItemData: foodItemData, atIndex: indexOfIngredient)
        } else {
            delegate?.ingredientEditedCancel()
        }
    }

    @IBAction func cancel(_ sender: UIButton) {
        delegate?.ingredientEditedCancel()
    }

}

extension IngredientEditorView: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard // let alternatives = alternatives,
            let foodItemData =  foodItemData else {
            return 0
        }
        let isOpenFood = foodItemData.isOpenFood ? 1 : 0
        if let alternatives = alternatives, !alternatives.isEmpty {
            return 4 + isOpenFood
        } else {
            return 3 + isOpenFood
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let foodItemData = foodItemData else {
            return UITableViewCell()
        }
        switch indexPath.row {
        case 0: // FoodHeaderMiniTableViewCell
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "FoodHeaderMiniTableViewCell",
                                                           for: indexPath) as? FoodHeaderMiniTableViewCell else {
                return UITableViewCell()
            }
            cell.labelName.text = foodItemData.name.capitalized
            cell.buttonAmount.isHidden = true
            let quantity = foodItemData.selectedQuantity
            let unitName = foodItemData.selectedUnit.capitalized
            let weight = String(Int(foodItemData.computedWeight.value))

            let textAmount = quantity == Double(Int(quantity)) ? String(Int(quantity)) :
            String(quantity.roundDigits(afterDecimal: 2))
            let weightText = unitName == "g" ? "" : "(" + weight + " " + "g".localized + ") "
            cell.labelServing.text = textAmount + " " + unitName + " " + weightText

            cell.calories.text = "0"
            if let cal = foodItemData.totalCalories?.value, 0 < cal, cal < 1e6 {
                cell.calories.text = String(Int(cal))
            }

            cell.carbs.text = "0"
            if let carbs = foodItemData.totalCarbs?.value, 0 < carbs, carbs < 1e6 {
                cell.carbs.text = String(Int(carbs))
            }

            cell.protein.text = "0"
            if let protein = foodItemData.totalProteins?.value, 0 < protein, protein < 1e6 {
                cell.protein.text = String(Int(protein))
            }

            cell.fat.text = "0"
            if let fat = foodItemData.totalFat?.value, 0 < fat, fat < 1e6 {
                cell.fat.text = String(Int(fat))
            }

            cell.passioIDForCell = foodItemData.passioID
            cell.imageFood.loadPassioIconBy(passioID: foodItemData.passioID,
                                            entityType: foodItemData.entityType) { passioIDForImage, image in
                if passioIDForImage == cell.passioIDForCell {
                    DispatchQueue.main.async {
                        cell.imageFood.image = image
                    }
                }
            }
            //            if let image = UIImage(named: foodItemData.name, in: bundlePod, compatibleWith: nil) {
            //                cell.imageFood.image = image
            //            } else {
            //                cell.imageFood.image = foodItemData.image
            //            }
            cell.tag = indexPath.row
            cell.imageFood.roundMyCorner()
            cell.labelCal.text = "Calories".localized
            cell.labelCarbs.text = "Carbs".localized
            cell.labelProtein.text = "Protein".localized
            cell.lableFat.text = "Fat".localized
            cell.selectionStyle = .none
            cell.insetBackground.backgroundColor = UIColor(named: Custom.insetBackgroundColor,
                                                           in: bundlePod, compatibleWith: nil)
            return cell
        case 1:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "AmountSliderMiniTableViewCell",
                                                           for: indexPath) as? AmountSliderMiniTableViewCell else {
                return UITableViewCell()
            }
            let (quantity, unitName, weight) = getAmountsforCell(tableRowOrCollectionTag: indexPath.row,
                                                                 slider: cell.sliderAmount)
            let textAmount = quantity == Double(Int(quantity)) ? String(Int(quantity)) :
            String(quantity.roundDigits(afterDecimal: 2))
            cell.textAmount.text = textAmount
            cell.textAmount.tag = indexPath.row
            cell.textAmount.textColor = .black
            cell.textAmount.backgroundColor = UIColor(named: "PassioLowContrast",
                                                      in: bundlePod, compatibleWith: nil)
            cell.textAmount.delegate = self
            cell.labelAmount.text = unitName == "g" ? "" : "(" + weight + " " + "g".localized + ") "
            let newTitle = " " + unitName + " " // title == "Gram" ? title : title + " (" + weight + " " + "Gram") + ") "
            cell.buttonUnits.setTitle(newTitle, for: .normal)
            cell.buttonUnits.tag = indexPath.row
            cell.buttonUnits.addTarget(self, action: #selector(changeLabel(sender:)), for: .touchUpInside)
            cell.sliderAmount.addTarget(self, action: #selector(sliderAmountValueDidChange(sender:)),
                                        for: .valueChanged)
            cell.tag = indexPath.row
            cell.selectionStyle = .none
            cell.insetBackground.backgroundColor = UIColor(named: Custom.insetBackgroundColor,
                                                           in: bundlePod, compatibleWith: nil)
            return cell
        case 2:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "AmountQuickMiniTableViewCell",
                                                           for: indexPath) as? AmountQuickMiniTableViewCell else {
                return UITableViewCell()
            }
            cell.tag = indexPath.row
            cell.selectionStyle = .none
            cell.insetBackground.backgroundColor = UIColor(named: Custom.insetBackgroundColor,
                                                           in: bundlePod, compatibleWith: nil)
            return cell
        case 3:
            if foodItemData.isOpenFood {
                return getOpenFoodCell(indexPath: indexPath)
            } else {
                if Custom.useNutritionBrowser {
                    return getAlternativeBrowserTableViewCell(indexPath: indexPath)
                } else {
                    return getAlternativesMiniTableViewCell(indexPath: indexPath)
                }
            }
        default:
            if Custom.useNutritionBrowser {
                return getAlternativeBrowserTableViewCell(indexPath: indexPath)
            } else {
                return getAlternativesMiniTableViewCell(indexPath: indexPath)
            }
        }
    }

    //    func getAlternativeBrowserTableViewCell(indexPath: IndexPath) ->  UITableViewCell {
    //        guard let cell = tableView.dequeueReusableCell(withIdentifier: "AlternativeBrowserTableViewCell",
    //                                                       for: indexPath) as? AlternativeBrowserTableViewCell else {
    //            return UITableViewCell()
    //        }
    //        cell.buttonSelectAlternative.isHidden = false
    //        cell.buttonSelectAlternative.addTarget(self, action: #selector(startNutritionBrowser), for: .touchUpInside)
    //        cell.buttonSelectAlternative.roundMyCornerWith(radius: Custom.buttonCornerRadius)
    //        cell.roundMyCornerWith(radius: Custom.insetBackgroundRadius)
    //        cell.contentView.backgroundColor = UIColor(named: Custom.insetBackgroundColor,
    //                                                       in: bundlePod, compatibleWith: nil)
    //        return cell
    //    }

    func getAlternativesMiniTableViewCell(indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "AlternativesMiniTableViewCell",
                                                       for: indexPath) as? AlternativesMiniTableViewCell
        else {
            return UITableViewCell()
        }
        cell.alternativesLabel.text = "Alternatives".localized
        cell.alternativesLabel.textColor = .black
        cell.tag = IndexForCollections.alternatives.rawValue
        cell.collectionViewHeight.constant = 52
        cell.selectionStyle = .none
        cell.insetBackground.backgroundColor = UIColor(named: Custom.insetBackgroundColor,
                                                       in: bundlePod, compatibleWith: nil)
        return cell
    }

    func getOpenFoodCell(indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(withIdentifier: "OpenFoodTableViewCell",
                                                       for: indexPath) as? OpenFoodTableViewCell else {
            return UITableViewCell()
        }
        cell.textView.backgroundColor = .clear
        cell.insetBackground.backgroundColor = UIColor(named: Custom.insetBackgroundColor,
                                                       in: bundlePod, compatibleWith: nil)
        return cell
    }

    @objc func dissmissPhoto(recognizer: UITapGestureRecognizer) {
        recognizer.view?.removeFromSuperview()
    }

    func getAmountsforCell(tableRowOrCollectionTag: Int, slider: UISlider) ->
    (quantity: Double, unitName: String, weight: String) {
        slider.minimumValue = 0.0
        slider.tag = tableRowOrCollectionTag
        guard let foodItemData = foodItemData else { return(0, "error", "0") }
        let sliderMultiplier: Float = 5.0
        let maxSliderFromData = Float(1) * sliderMultiplier
        let currentValue = Float(foodItemData.selectedQuantity)

        if cachedMaxForSlider[tableRowOrCollectionTag]?[foodItemData.selectedUnit] == nil {
            cachedMaxForSlider[tableRowOrCollectionTag] = [foodItemData.selectedUnit: sliderMultiplier * currentValue]
            slider.maximumValue = sliderMultiplier * currentValue
        } else if let maxFromCache = cachedMaxForSlider[tableRowOrCollectionTag]?[foodItemData.selectedUnit],
                  maxFromCache > maxSliderFromData, maxFromCache > currentValue {
            slider.maximumValue = maxFromCache
        } else  if maxSliderFromData > currentValue {
            slider.maximumValue = maxSliderFromData
        } else {
            slider.maximumValue = currentValue
            cachedMaxForSlider[tableRowOrCollectionTag] = [foodItemData.selectedUnit: currentValue]
        }
        slider.value = currentValue
        return (Double(currentValue), foodItemData.selectedUnit.capitalized,
                String(Int(foodItemData.computedWeight.value)))
    }

    @objc func sliderAmountValueDidChange(sender: UISlider) {
        let maxSlider = Int(sender.maximumValue)
        var sizeOfAtTick: Double
        switch maxSlider {
        case 0..<10:
            sizeOfAtTick = 0.5
        case 10..<100:
            sizeOfAtTick = 1
        case 100..<500:
            sizeOfAtTick = 1
        default:
            sizeOfAtTick = 10
        }
        let previousValue = foodItemData?.selectedQuantity
        var newValue = round(Double(sender.value)/sizeOfAtTick) * sizeOfAtTick
        guard newValue != previousValue else {
            return
        }
        if let unit = foodItemData?.selectedUnit {
            newValue = newValue == 0 ? sizeOfAtTick/1000 : newValue
            _ = foodItemData?.setFoodItemDataServingSize(unit: unit, quantity: newValue )
        }
        tableView.reloadData()
    }

    func getAlternativeBrowserTableViewCell(indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "AlternativeBrowserTableViewCell",
                                                       for: indexPath) as? AlternativeBrowserTableViewCell else {
            return UITableViewCell()
        }
        cell.buttonSelectAlternative.isHidden = alternatives == nil
        cell.buttonSelectAlternative.addTarget(self, action: #selector(startNutritionBrowser), for: .touchUpInside)
        cell.buttonSelectAlternative.roundMyCornerWith(radius: Custom.buttonCornerRadius)
        cell.roundMyCornerWith(radius: Custom.insetBackgroundRadius)
        cell.contentView.backgroundColor = UIColor(named: Custom.insetBackgroundColor,
                                                   in: bundlePod, compatibleWith: nil)
        return cell
    }

    @objc func startNutritionBrowser() {
        if let foodItemData = foodItemData {
            delegate?.startNutritionBrowser(foodItemData: foodItemData)
        }
    }
}

extension IngredientEditorView: UITableViewDelegate {

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let cell = cell as? AlternativesMiniTableViewCell {
            cell.setCollectionViewDataSourceDelegate(dataSourceDelegate: self, forRow: indexPath.row)
        } else if let cell = cell as? AmountQuickMiniTableViewCell {
            cell.setCollectionViewDataSourceDelegate(dataSourceDelegate: self, forRow: indexPath.row)
            guard let foodItemData = foodItemData else { return }
            for (index, amount) in foodItemData.servingSizes.enumerated() where
            (amount.unitName == foodItemData.selectedUnit && amount.quantity == foodItemData.selectedQuantity) {
                cell.collectionAmounts.scrollToItem(at: IndexPath(item: index, section: 0),
                                                    at: .left, animated: false)
            }
        }
    }

}

extension IngredientEditorView: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch collectionView.tag {
        case 2:
            return foodItemData?.servingSizes.count ?? 0
        case 3:
            if let foodItemData = foodItemData {
                let tempAlt = (foodItemData.parentsPassioID ?? []) +
                (foodItemData.childrenPassioID ?? []) +
                (foodItemData.siblingsPassioID ?? [])
                return tempAlt.count
            } else {
                return  0
            }
        default:
            return 0
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        CellNameCollections.allCases.forEach {
            let cell = UINib(nibName: $0.rawValue.capitalizingFirst(), bundle: bundlePod)
            collectionView.register(cell, forCellWithReuseIdentifier: $0.rawValue)
        }
        let cellNameAltFlat = "AlternativesFlatCollectionViewCell"
        let cellRegister = UINib(nibName: cellNameAltFlat, bundle: bundlePod)
        collectionView.register(cellRegister, forCellWithReuseIdentifier: cellNameAltFlat)

        switch collectionView.tag {
        case 2:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AmountCollectionViewCell",
                                                                for: indexPath) as? AmountCollectionViewCell else {
                return UICollectionViewCell()
            }
            //            cell.labelAmountCollection.layer.borderColor = color.cgColor
            //            cell.labelAmountCollection.layer.masksToBounds = true
            //            cell.labelAmountCollection.layer.borderWidth = 1
            cell.labelAmountCollection?.roundMyCorner()
            if let amounts = foodItemData?.servingSizes {
                let amountDouble = amounts[indexPath.row].quantity.roundDigits(afterDecimal: 2)
                let amountValue = amountDouble == Double(Int(amountDouble)) ?
                String(Int(amountDouble)) : String(amountDouble)
                cell.labelAmountCollection?.text = "\(amountValue) \(amounts[indexPath.row].unitName)"
            }
            cell.labelAmountCollection?.textColor = .black
            cell.labelAmountCollection?.backgroundColor = UIColor(named: "PassioLowContrast",
                                                                  in: bundlePod, compatibleWith: nil)
            return cell
        case 3:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellNameAltFlat,
                                                                for: indexPath) as? AlternativesFlatCollectionViewCell else {
                return UICollectionViewCell()
            }
            let (name, image) = getAlternativeForIndex(index: indexPath.row)
            cell.labelAlternativeName.text = name.capitalized
            cell.imageAlternative?.image = image
            cell.labelAlternativeName.textColor = .black
            cell.roundMyCorner()
            cell.backgroundColor = UIColor(named: "PassioLowContrast")
            return cell
        default:
            return UICollectionViewCell()
        }
    }

}

extension IngredientEditorView: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell,
                        forItemAt indexPath: IndexPath) {
        if let cell = cell as? AmountCollectionViewCell {
            if foodItemData?.servingSizes[indexPath.row].unitName == foodItemData?.selectedUnit,
               foodItemData?.servingSizes[indexPath.row].quantity == foodItemData?.selectedQuantity {
                cell.labelAmountCollection.textColor = .black
                cell.labelAmountCollection.backgroundColor = UIColor(named: "PassioMedContrast",
                                                                     in: bundlePod,
                                                                     compatibleWith: nil)
            }
        }
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch collectionView.tag {
        case 2: // amounts optioons
            guard let amountOption = foodItemData?.servingSizes[indexPath.row] else { return }
            _ = foodItemData?.setFoodItemDataServingSize(unit: amountOption.unitName, quantity: amountOption.quantity)
            tableView.reloadData()
        case 3: // Alternatives
            foodItemData = getFoodItemDataAlternativeForIndex(index: indexPath.row)
        default:
            print("Error didSelectItemAt")
        }
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        switch collectionView.tag {
        case 2: // Amount options
            let label = UILabel()
            // label.text
            guard let amounts = foodItemData?.servingSizes, indexPath.row < amounts.count else {
                return CGSize(width: 100, height: 40)
            }

            let amount = amounts[indexPath.row]

            label.text = String(amount.quantity) + amount.unitName
            label.sizeToFit()
            var fagfactor = 1.0
            if label.text!.count < 5 {
                fagfactor = 1.1
            }
            let size = CGSize(width: 24.0 + Double(label.frame.width)*fagfactor, height: 40)
            return size
        case 3:
            let (alternativeTitle, _) = getAlternativeForIndex(index: indexPath.row)

            let label = UILabel()
            label.numberOfLines = 2
            let words = alternativeTitle.components(separatedBy: .whitespacesAndNewlines)
            var sizeForText = Double()
            if words.count == 1 {
                label.text = alternativeTitle
                label.sizeToFit()
                sizeForText = Double(label.frame.width)
                if words.first!.count < 6 {
                    sizeForText += 10
                }
            } else if words.count == 2 {
                let maxWord = words.max {$1.count > $0.count}
                label.text = maxWord
                label.sizeToFit()
                sizeForText = Double(label.frame.width)*1.1
                if maxWord!.count < 6 {
                    sizeForText += 10
                }
            } else if words.count == 3 {
                let maxCount = max(words[0].count, words[2].count)
                if maxCount == (words[0].count) {
                    let maxCount = max(words[0].count, (words[1].count + 1 + words[2].count))
                    if maxCount == words[0].count {
                        label.text = words[0]
                    } else {
                        label.text = words[1] + " " + words[2]
                    }
                } else {
                    let maxCount = max(words[0].count + 1 + words[1].count, words[2].count)
                    if maxCount == words[2].count {
                        label.text = words[2]
                    } else {
                        label.text = words[0] + " " + words[1]
                    }
                }
                label.sizeToFit()
                sizeForText = Double(label.frame.width)
            } else {
                label.text = alternativeTitle
                label.sizeToFit()
                sizeForText = Double(label.frame.width)/2
            }
            return CGSize(width: 50.0 + sizeForText, height: 40)
        default:
            print("Error layout collectionViewLayout ")
            return CGSize(width: 0, height: 40)
        }
    }

    func getAlternativeForIndex(index: Int) -> (name: String, image: UIImage?) {
        var name = "No name"
        var image: UIImage?

        if let alt = alternatives, alt.count > index {
            let alternative = alt[index]
            name = alternative.name
            let passioID = alternative.passioID
            (image, _) =  passioSDK.lookupIconFor(passioID: passioID)
        }
        return (name, image)
    }

    func getFoodItemDataAlternativeForIndex(index: Int) -> PassioFoodItemData? {
        if let alt = alternatives, alt.count > index {
            let pID = alt[index].passioID
            if let pAtt = passioSDK.lookupPassioIDAttributesFor(passioID: pID) {
                return pAtt.passioFoodItemData
            }
        }
        return nil
    }
}

extension IngredientEditorView: UnitPickerViewDelegate {

    func userSelected(label: String, tableTag: Int) {
        _ = foodItemData?.setServingUnitKeepWeight(unitName: label)
        tableView.reloadData()
    }

}

extension IngredientEditorView: UITextFieldDelegate {

    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        let kbToolBarView = UIToolbar.init(frame: CGRect(x: 0, y: 0, width: frame.size.width, height: 44))
        let kbSpacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace,
                                       target: nil, action: nil)
        let bottonOk = UIBarButtonItem(title: "OK".localized, style: .plain, target: self,
                                       action: #selector(closeKeyBoard(barButtonItem:)))
        bottonOk.tag = textField.tag
        kbToolBarView.items = [kbSpacer, bottonOk, kbSpacer]
        kbToolBarView.tintColor = .white
        kbToolBarView.barTintColor = UIColor(named: "CustomBase")
        textField.inputAccessoryView = kbToolBarView
        frame.origin.y -= 180
        return true
    }

    @objc func closeKeyBoard(barButtonItem: UIBarButtonItem) {
        if let fvc = self.findViewController() {
            fvc.view.endEditing(true)
        }
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        if let text = textField.text, text.contains("."), string == "." {
            return false
        } else {// if let text = textField.text, text.count =< 5 {
            return true
        }
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        frame.origin.y += 180
        if let textGerman = textField.text {
            let text = textGerman.replacingOccurrences(of: ",", with: ".")
            if let quantity = Double(text),
               var tempfoodItemData = foodItemData {
                _ = tempfoodItemData.setFoodItemDataServingSize(unit: tempfoodItemData.selectedUnit, quantity: quantity)
                foodItemData = tempfoodItemData
            }
        }
        tableView.reloadData()
    }

}
