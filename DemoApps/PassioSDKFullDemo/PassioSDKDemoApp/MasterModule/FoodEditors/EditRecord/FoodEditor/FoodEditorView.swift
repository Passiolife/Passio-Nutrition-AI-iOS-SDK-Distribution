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

protocol FoodEditorDelegate: AnyObject {
    func addFoodToLog(foodRecord: FoodRecord)
    func addFoodFavorites(foodRecord: FoodRecord)
    func foodEditorCancel()
    func userSelected(foodRecord: FoodRecord)
    func userSelected(ingredient: PassioFoodItemData, indexOfIngredient: Int)
    func foodEditorSearchText()
    func foodEditorRequest(pauseRecognition: Bool)
    func animateMicroTotheLeft()
    func startNutritionBrowser(foodRecord: FoodRecord)
    func rescanVolume()
}

extension FoodEditorDelegate {
    func userSelected(foodRecord: FoodRecord) { }
    func userSelected(ingredient: PassioFoodItemData, indexOfIngredient: Int) {}
    func foodEditorSearchText() {}
    func foodEditorRequest(pauseRecognition: Bool) {}
}

class FoodEditorView: UIView {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var buttonCancel: UIButton!
    @IBOutlet weak var buttonAddToFavorites: UIButton!
    @IBOutlet weak var buttonSave: UIButton!

    let passioSDK = PassioNutritionAI.shared
    let connector = PassioInternalConnector.shared
    let bundlePod = PassioInternalConnector.shared.bundleForModule
    let rowsBeforeIngrediants = 5
    let rowForAlternatives = 3
    weak var delegate: FoodEditorDelegate?
    var isMicroAlternatives = false
    var isMiniEditor = false
    var isMiniEditorInMultipleFood = false
    // state
    var saveToConnector = true
    var isEditingFavorite = false
    var favoriteButtonIsAlwaysHidden = false {
        didSet {
            buttonAddToFavorites?.isHidden = favoriteButtonIsAlwaysHidden
        }
    }
    var foodRecord: FoodRecord? {
        didSet {
            if foodRecord != nil {
                fetchFavorites()
                // will refresh when favorites are set
                if !favoriteButtonIsAlwaysHidden {
                    buttonAddToFavorites?.isHidden = isEditingFavorite
                }
                if foodRecord?.ingredients.count == 1 {
                    showAmount = true
                }
            } else {
                favorites = []
            }
            tableView.reloadWithAnimations(withDuration: 0.2)
        }
    }

    var favorites = [FoodRecord]() {
        willSet(newValue) {
            if newValue != favorites {
                tableView.reloadWithAnimations()
            }
        }
    }

    func fetchFavorites() {
        connector.fetchFavorites { favorites in
            self.favorites = favorites.filter {
                $0.passioID == self.foodRecord?.passioID
            }.sorted {
                $0.createdAt > $1.createdAt
            }
        }
    }

    var showAmount = false {
        didSet {
            tableView.reloadWithAnimations()
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.allowsSelection = true
        tableView.estimatedRowHeight = 200

//        let image = UIImage(named: "bttn_bg",
//                            in: bundlePod,
//                            compatibleWith: nil)
//        buttonCancel?.setBackgroundImage(image, for: .normal)
        buttonCancel?.setTitle( "Cancel", for: .normal)
        buttonAddToFavorites?.setTitle("Favorites", for: .normal)
//        buttonAddToFavorites?.setBackgroundImage(image, for: .normal)
        buttonSave?.setTitle( "Save", for: .normal)
//        buttonSave?.setBackgroundImage(image, for: .normal)
        buttonCancel?.roundMyCornerWith(radius: Custom.buttonCornerRadius)
        buttonAddToFavorites?.roundMyCornerWith(radius: Custom.buttonCornerRadius)
        buttonSave?.roundMyCornerWith(radius: Custom.buttonCornerRadius)
        CellNameFoodEditor.allCases.forEach {
            let cellName = $0.rawValue.capitalizingFirst()
            let cell = UINib(nibName: cellName, bundle: bundlePod)
            tableView.register(cell, forCellReuseIdentifier: cellName)
        }
    }

    //    // MARK: Button Actions.
    @objc func changeLabel(sender: UIButton ) {
        guard let servingUnits = foodRecord?.servingUnits,
              let unitPickerView = Bundle.main.loadNibNamed("UnitPickerView", owner: nil,
                                                            options: nil)?.first as? UnitPickerView else {
            return
        }
        let widthForPicker = bounds.width - 40.0
        let heightForPicker: CGFloat = 240.0
        let convertHeight = sender.convert(sender.frame.origin, to: self)
        unitPickerView.frame = CGRect(x: 20.0, y: convertHeight.y - heightForPicker/2,
                                      width: widthForPicker, height: heightForPicker)
        // print( "servingUnits ====== \(servingUnits)")
        unitPickerView.labelsForPicker = servingUnits.map { return $0.unitName }
        //   unitPickerView.labelsForPicker = foodRecord?.amountQuickOptions.map {return $0.label}
        // model.getAmoutsLabelsForCell(tableRowOrCollectionTag: sender.tag)
        unitPickerView.tag = sender.tag
        unitPickerView.indexForSelectedUnit = 0
        unitPickerView.delegate = self
        addSubview(unitPickerView)
    }

    @IBAction func cancel(_ sender: UIButton) {
        delegate?.foodEditorCancel()
    }

    @IBAction func addToFavorites(_ sender: UIButton) {
        guard let foodRecord = foodRecord else { return }
        var favorite = foodRecord
        let alertFavorite = UIAlertController(title: "Name your favorite".localized,
                                              message: nil, preferredStyle: .alert)
        alertFavorite.addTextField { (textField) in
            textField.placeholder = "My " + favorite.name.capitalized
            textField.clearButtonMode = .always
        }
        let save = UIAlertAction(title: "Save".localized, style: .default) { (_) in
            let firstTextFied = alertFavorite.textFields![0] as UITextField

            // favorite.isFavorite = true
            if self.isEditingFavorite {
                favorite.uuid = UUID().uuidString
            }
            favorite.createdAt = Date()
            if let text = firstTextFied.text, !text.isEmpty {
                favorite.name = text
            } else {
                favorite.name = "My " + favorite.name
            }

            if self.saveToConnector {
                self.connector.updateFavorite(foodRecord: favorite)
            }
            self.delegate?.addFoodFavorites(foodRecord: favorite)
            self.tableView.reloadData()
        }
        let cancel = UIAlertAction(title: "Cancel".localized, style: .cancel)
        alertFavorite.addAction(save)
        alertFavorite.addAction(cancel)
        self.findViewController()?.present(alertFavorite, animated: true)
    }

    @IBAction func addToLog(_ sender: UIButton) {
        guard let record = foodRecord else { return }
        if !isMiniEditorInMultipleFood {
            if saveToConnector {
                connector.updateRecord(foodRecord: record, isNew: true )
            }
        }

        if let  nutritionalPassioID = record.nutritionalPassioID,
           let visualPassioID = record.visualPassioID {
            let personalized = PersonalizedAlternative(visualPassioID: visualPassioID,
                                                       nutritionalPassioID: nutritionalPassioID,
                                                       servingUnit: record.selectedUnit,
                                                       servingSize: record.selectedQuantity)
            passioSDK.addToPersonalization(personalizedAlternative: personalized)
        }
        delegate?.addFoodToLog(foodRecord: record)
    }

    @IBAction func saveFoodRecord(_ sender: UIButton) {
        guard let foodRecord = foodRecord else { return }
        if saveToConnector {
            if isEditingFavorite {// foodRecord.isFavorite {
                connector.updateFavorite(foodRecord: foodRecord)
            } else {
                connector.updateRecord(foodRecord: foodRecord, isNew: false)
            }
        }
        delegate?.addFoodToLog(foodRecord: foodRecord)
    }

    func getCellNameFor(indexPath: IndexPath) -> CellNameFoodEditor {
        switch indexPath.row {
        case 0:
            return .foodHeaderFullTableViewCell
        case 1:
            return .amountSliderFullTableViewCell
        case 2:
            return .amountQuickMiniTableViewCell
        case rowForAlternatives:
            if Custom.useNutritionBrowser {
                return .alternativeBrowserTableViewCell
            } else {
                return .alternativesMiniTableViewCell
            }
        case 4:
            return .mealSelectionTableViewCell
        case 5:
            if foodRecord?.isOpenFood ?? false {
                return .openFoodTableViewCell
            } else {
                return .ingredientAddTableViewCell
            }
        case 6:
            if foodRecord?.isOpenFood ?? false {
                return .ingredientAddTableViewCell
            } else {
                return .ingredientHeaderTableViewCell
            }
        default:
            return .ingredientHeaderTableViewCell
        }
    }

    private var privateFavorites = [FoodRecord]()
    private var cachedMaxForSlider = [Int: [String: Float]]()

    var showAlternativesRow: Bool {
        guard let foodRecord = foodRecord else { return false }
        if foodRecord.alternativesPassioID != nil || !favorites.isEmpty {
            if foodRecord.entityType == .item ||
                foodRecord.entityType == .group ||
                foodRecord.entityType == .recipe ||
                foodRecord.entityType == .barcode ||
                foodRecord.entityType == .packagedFoodCode {
                return true
            }
        }
        return false
    }

}

extension FoodEditorView: UITableViewDataSource {

    var calculatedNumberOfRaws: Int {
        guard let foodRecord = foodRecord else { return 0 }
        let numOfIngredients = foodRecord.ingredients.count
        let withoutAlternatives = numOfIngredients == 1 ? rowsBeforeIngrediants : rowsBeforeIngrediants + numOfIngredients
        let openFood = foodRecord.isOpenFood ? 1 : 0
        return withoutAlternatives + openFood + 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       calculatedNumberOfRaws
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

        if isMicroAlternatives {
            return UITableView.automaticDimension
        }
        if !showAmount, (indexPath.row == 1 || indexPath.row == 2) { // hide cell
            return 0
        }
        if indexPath.row == rowForAlternatives, let foodRecord = foodRecord { //
            if foodRecord.entityType == .recipe {
                if isMiniEditor || isMiniEditorInMultipleFood {
                    return UITableView.automaticDimension
                } else {
                    return UITableView.automaticDimension // 0 // remove alternatives from recipe.
                }
            } else if (foodRecord.alternativesPassioID == nil ||
                            foodRecord.alternativesPassioID?.count == 0),
                      favorites.count == 0, !isMicroAlternatives {
                return 0 // remove is not alternatives or favorites
            }
        }
        return UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cellName = getCellNameFor(indexPath: indexPath)
        switch cellName {
        case .foodHeaderFullTableViewCell:
            return getFoodHeaderFullTableViewCell(cellForRowAt: indexPath)
        case .foodHeaderMiniTableViewCell:
            return getFoodHeaderMiniTableViewCell(cellForRowAt: indexPath)
        case .foodHeaderMicroTableViewCell:
            return getFoodHeaderMicroTableViewCell(cellForRowAt: indexPath)
        case .amountSliderFullTableViewCell:
            return getAmountSliderFullTableViewCell(indexPath: indexPath)
        case .ingredientAddTableViewCell:
            return getIngredientAddTableViewCell(indexPath: indexPath)
        case .alternativesMiniTableViewCell:
            return getAlternativesMiniTableViewCell(indexPath: indexPath)
        case .alternativesMicroTableViewCell:
            return getAlternativesMicroTableViewCell(indexPath: indexPath)
        case .amountQuickMiniTableViewCell:
            return getAmountQuickMiniTableViewCell(indexPath: indexPath)
        case .amountSliderMiniTableViewCell:
            return getAmountSliderMiniTableViewCell(indexPath: indexPath)
        case .ingredientHeaderTableViewCell:
            return getIngredientHeaderTableViewCell(indexPath: indexPath)
        case .alternativeBrowserTableViewCell:
            return getAlternativeBrowserTableViewCell(indexPath: indexPath)
        case .mealSelectionTableViewCell:
            return getMealSelectionCell(indexPath: indexPath)
        case .openFoodTableViewCell:
            return getOpenFoodCell(indexPath: indexPath)
        }
    }

    @objc func toogleShowAmounts() {
        showAmount.toggle()
    }

    //    @objc func showPhoto() {
    //        guard let foodRecord = foodRecord, let photo = connector.getPhotoFor(uuid: foodRecord.uuid) else { return }
    //        let imageView = UIImageView(image: photo)
    //        imageView.frame = self.bounds
    //        imageView.contentMode = .scaleAspectFill
    //        let recognizer = UITapGestureRecognizer(target: self, action: #selector(dissmissPhoto(recognizer:)))
    //        imageView.isUserInteractionEnabled = true
    //        imageView.addGestureRecognizer(recognizer)
    //        addSubview(imageView)
    //    }

    @objc func dissmissPhoto(recognizer: UITapGestureRecognizer) {
        recognizer.view?.removeFromSuperview()
    }

    func getAmountsforCell(tableRowOrCollectionTag: Int, slider: UISlider) ->
    (quantity: Double, unitName: String, weight: String) {
        slider.minimumValue = 0.0
        slider.tag = tableRowOrCollectionTag
        guard let foodRecord = foodRecord else { return(0, "error", "0") }
        let sliderMultiplier: Float = 5.0
        let maxSliderFromData = Float(1) * sliderMultiplier
        let currentValue = Float(foodRecord.selectedQuantity)

        if cachedMaxForSlider[tableRowOrCollectionTag]?[foodRecord.selectedUnit] == nil {
            cachedMaxForSlider[tableRowOrCollectionTag] = [foodRecord.selectedUnit: sliderMultiplier * currentValue]
            slider.maximumValue = sliderMultiplier * currentValue
        } else if let maxFromCache = cachedMaxForSlider[tableRowOrCollectionTag]?[foodRecord.selectedUnit],
                  maxFromCache > maxSliderFromData, maxFromCache > currentValue {
            slider.maximumValue = maxFromCache
        } else if maxSliderFromData > currentValue {
            slider.maximumValue = maxSliderFromData
        } else {
            slider.maximumValue = currentValue
            cachedMaxForSlider[tableRowOrCollectionTag] = [foodRecord.selectedUnit: currentValue]
        }
        slider.value = currentValue
        return (Double(currentValue), foodRecord.selectedUnit.capitalized,
                String(Int(foodRecord.computedWeight.value)))
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
        var newValue = round(Double(sender.value)/sizeOfAtTick) * sizeOfAtTick
        guard newValue != foodRecord?.selectedQuantity,
                var tempFoodRecord = foodRecord else {
            return
        }
        newValue = newValue == 0 ? sizeOfAtTick/1000 : newValue
        _ = tempFoodRecord.setFoodRecordServing(unit: tempFoodRecord.selectedUnit, quantity: newValue )
        foodRecord = tempFoodRecord
        // tableView.reloadWithAnimations(withDuration: 0.1)
    }

    @objc func renameFoodRecordAlert() {
        let alertName = UIAlertController(title: "Rename Food Record".localized, message: nil, preferredStyle: .alert)
        alertName.addTextField { (textField) in
            textField.text = self.foodRecord?.name ?? "Error2"
            textField.clearButtonMode = .always
        }
        let save = UIAlertAction(title: "Save".localized, style: .default) { (_) in
            let firstTextField = alertName.textFields![0] as UITextField
            guard self.foodRecord != nil, let newName = firstTextField.text else { return }
            self.foodRecord?.name = newName
            if self.saveToConnector, let foodRecord = self.foodRecord {
                if self.isEditingFavorite { // self.foodRecord!.isFavorite {
                    self.connector.updateFavorite(foodRecord: foodRecord)
                } else {
                    self.connector.updateRecord(foodRecord: foodRecord, isNew: false)
                }
            }
            self.tableView.reloadData()
        }
        let cancel = UIAlertAction(title: "Cancel".localized, style: .cancel) { (_) in
        }
        alertName.addAction(save)
        alertName.addAction(cancel)
        self.findViewController()?.present(alertName, animated: true)
    }

}

extension FoodEditorView: UITableViewDelegate {

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let cell = cell as? AlternativesMiniTableViewCell {
            cell.setCollectionViewDataSourceDelegate(dataSourceDelegate: self,
                                                     forRow: IndexForCollections.alternatives.rawValue)// indexPath.row)
        } else if let cell = cell as? AlternativesMicroTableViewCell {
            cell.setCollectionViewDataSourceDelegate(dataSourceDelegate: self,
                                                     forRow: IndexForCollections.alternatives.rawValue)// indexPath.row)
        } else if let cell = cell as? AmountQuickMiniTableViewCell {
            cell.setCollectionViewDataSourceDelegate(dataSourceDelegate: self,
                                                     forRow: IndexForCollections.amountQuickMini.rawValue)
            guard let foodRecord = foodRecord else { return }
            for (index, amount) in foodRecord.servingSizes.enumerated() where
                (amount.unitName == foodRecord.selectedUnit && amount.quantity == foodRecord.selectedQuantity) {
                cell.collectionAmounts.scrollToItem(at: IndexPath(item: index, section: 0),
                                                    at: .left, animated: false)
            }
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row > rowsBeforeIngrediants, let foodRecord = foodRecord {

            let openFood = foodRecord.isOpenFood ? 1 : 0
            let index = indexPath.row - rowsBeforeIngrediants - 1 - openFood
            guard foodRecord.ingredients.count > index  else { return }
            let foodItem = foodRecord.ingredients[index]
            delegate?.userSelected(ingredient: foodItem, indexOfIngredient: index)
        }
    }

    func tableView(_ tableView: UITableView,
                   trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard indexPath.row > rowsBeforeIngrediants else { return nil }
        let deleteItem = UIContextualAction(style: .destructive, title: "Delete".localized) {  (_, _, _) in
            let index = indexPath.row - self.rowsBeforeIngrediants - 1
            // ("index to remove = ", index)
            _ = self.foodRecord?.removeIngredient(atIndex: index)
        }
        let swipeActions = UISwipeActionsConfiguration(actions: [deleteItem])
        return swipeActions
    }

    func tableView(_ tableView: UITableView,
                   editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        // print("indexPath.row =", indexPath.row)
        return indexPath.row > rowsBeforeIngrediants ? .delete : .none
    }
}

extension FoodEditorView: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch collectionView.tag {
        case IndexForCollections.amountQuickMini.rawValue:
            return foodRecord?.servingSizes.count ?? 0
        case IndexForCollections.alternatives.rawValue: // Alternatives
            return (foodRecord?.alternativesPassioID?.count ?? 0) + favorites.count
        default:
            return 0
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        CellNameCollections.allCases.forEach {
            let cell = UINib(nibName: $0.rawValue.capitalizingFirst(), bundle: bundlePod)
            collectionView.register(cell, forCellWithReuseIdentifier: $0.rawValue)
        }

        switch collectionView.tag {
        case IndexForCollections.amountQuickMini.rawValue:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AmountCollectionViewCell",
                                                                for: indexPath) as? AmountCollectionViewCell else {
                return UICollectionViewCell()
            }
            cell.labelAmountCollection?.roundMyCorner()
            let amounts = foodRecord!.servingSizes
            let amountDouble = amounts[indexPath.row].quantity.roundDigits(afterDecimal: 2)
            let amountValue = amountDouble == Double(Int(amountDouble)) ? String(Int(amountDouble)) :
                String(amountDouble)
            cell.labelAmountCollection?.text = "\(amountValue) \(amounts[indexPath.row].unitName)"
            cell.labelAmountCollection.textColor = .black
            //                UIColor(named: "CustomBase",
            //                                                           in: bundlePod, compatibleWith: nil)
            cell.labelAmountCollection.backgroundColor = UIColor(named: "PassioLowContrast",
                                                                 in: bundlePod, compatibleWith: nil)
            return cell
        case IndexForCollections.alternatives.rawValue:
            if isMicroAlternatives {
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AlternativesMicroCollectionViewCell",
                                                                    for: indexPath) as? AlternativesMicroCollectionViewCell else {
                    return UICollectionViewCell()
                }

                let (name, passioID) = getAlternativeForIndex(index: indexPath.row)
                cell.labelAlternativeName.text = name.capitalized
                cell.passioIDForCell = passioID
                cell.imageAlternative?.loadPassioIconBy(passioID: passioID,
                                                        entityType: .item) { passioIDForImage, image in
                    if passioIDForImage == cell.passioIDForCell {
                        DispatchQueue.main.async {
                            cell.imageAlternative?.image = image
                        }
                    }
                }

                cell.roundMyCorner()
                cell.tag = IndexForCollections.alternatives.rawValue
                cell.labelAlternativeName.textColor = .black

                cell.backgroundColor = UIColor(named: "PassioLowContrast",
                                               in: bundlePod, compatibleWith: nil)
                return cell
            } else {
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AlternativesFlatCollectionViewCell",
                                                                    for: indexPath) as? AlternativesFlatCollectionViewCell else {
                    return UICollectionViewCell()
                }
                let (name, passioID) = getAlternativeForIndex(index: indexPath.row)
                cell.labelAlternativeName.text = name.capitalized
                cell.passioIDForCell = passioID
                cell.imageAlternative?.loadPassioIconBy(passioID: passioID,
                                                        entityType: .item) { passioIDForImage, image in
                    if passioIDForImage == cell.passioIDForCell {
                        DispatchQueue.main.async {
                            cell.imageAlternative?.image = image
                        }
                    }
                }
                cell.roundMyCorner()
                cell.tag = IndexForCollections.alternatives.rawValue
                cell.labelAlternativeName.textColor = .black
                cell.backgroundColor = UIColor(named: "PassioLowContrast",
                                               in: bundlePod, compatibleWith: nil)
                return cell
            }
        default:
            return UICollectionViewCell()
        }
    }

    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell,
                        forItemAt indexPath: IndexPath) {
        if let cell = cell as? AmountCollectionViewCell {
            if foodRecord?.servingSizes[indexPath.row].unitName == foodRecord?.selectedUnit,
               foodRecord?.servingSizes[indexPath.row].quantity == foodRecord?.selectedQuantity {
                cell.labelAmountCollection.textColor = .black
                cell.labelAmountCollection.backgroundColor = UIColor(named: "PassioMedContrast",
                                                                     in: bundlePod,
                                                                     compatibleWith: nil)
            }
        }
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch collectionView.tag {
        case IndexForCollections.amountQuickMini.rawValue: // amounts optioons
            guard let amountOption = foodRecord?.servingSizes[indexPath.row] else { return }
            _ = foodRecord?.setFoodRecordServing(unit: amountOption.unitName, quantity: amountOption.quantity)
            tableView.reloadData()
        case IndexForCollections.alternatives.rawValue: // Alternatives
            if var record = getFoodRecordAlternativeForIndex(index: indexPath.row),
               let foodRecord = foodRecord {
                // record.isFavorite = foodRecord.isFavorite
                record.uuid = foodRecord.uuid
                self.foodRecord = record
                delegate?.foodEditorRequest(pauseRecognition: true)
            }
        default:
            print("Error didSelectItemAt")
        }
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        switch collectionView.tag {
        case IndexForCollections.amountQuickMini.rawValue: // Amount options
            let label = UILabel()
            // label.text

            let heightAmountColCell = 40.0
            guard let amounts = foodRecord?.servingSizes, indexPath.row < amounts.count else {
                return CGSize(width: 100, height: heightAmountColCell)
            }
            let amount = amounts[indexPath.row]

            label.text = String(amount.quantity) + amount.unitName
            label.sizeToFit()
            var fagfactor = 1.0
            if label.text!.count < 5 {
                fagfactor = 1.1
            }
            let size = CGSize(width: 24.0 + Double(label.frame.width)*fagfactor, height: heightAmountColCell)
            return size
        case IndexForCollections.alternatives.rawValue:
            let (alternativeTitle, _) = getAlternativeForIndex(index: indexPath.row)

            let heightAltColCell = isMicroAlternatives ? 40.0 : 40.0 // Can be removed
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
            return CGSize(width: 44.0 + sizeForText, height: heightAltColCell)
        default:
            print("Error layout collectionViewLayout ")
            return CGSize(width: 0, height: 40)
        }
    }

    func getAlternativeForIndex(index: Int) -> (name: String, passiID: PassioID) {
        var name = "No name"
        var passioID = "No passioID "
        if index < favorites.count {
            let favorite = favorites[index]
            name = favorite.name
            passioID = favorite.passioID
        } else if let alt = foodRecord?.alternatives, alt.count > (index - favorites.count) {
            let aIndex = index - favorites.count
            let alternative = alt[aIndex]
            name = alternative.name
            passioID = alternative.passioID
        }
        return (name, passioID)
    }

    func getFoodRecordAlternativeForIndex(index: Int) -> FoodRecord? {
        if index < favorites.count {
            return favorites[index]
        } else if let alt = foodRecord?.alternativesPassioID,
                  alt.count > (index - favorites.count) {
            let aIndex = index - favorites.count
            let pID = alt[aIndex]
            if let pAtt = passioSDK.lookupPassioIDAttributesFor(passioID: pID) {
                let newFoodRecord = FoodRecord(passioIDAttributes: pAtt,
                                               replaceVisualPassioID: foodRecord?.visualPassioID,
                                               replaceVisualName: foodRecord?.visualName)
//                if let currentFoodRecord = foodRecord  {
//                    print("There is a currentFoodRecord record ")
//                    print("ID Attributes *** passioID = \(currentFoodRecord.passioID) visualPassioID = \(String(describing: currentFoodRecord.visualPassioID)) nutritionalPassioID = \(String(describing: currentFoodRecord.nutritionalPassioID))")
//                    //newFoodRecord.visualPassioID = currentFoodRecord.visualPassioID
//                }
//                print("There is a New food record record ")
//                print("ID Attributes *** passioID = \(newFoodRecord.passioID) visualPassioID = \(String(describing: newFoodRecord.visualPassioID)) nutritionalPassioID = \(String(describing: newFoodRecord.nutritionalPassioID))")
                return newFoodRecord
            }
        }
        return nil
    }
}

extension FoodEditorView: UnitPickerViewDelegate {

    func userSelected(label: String, tableTag: Int) {
       _ = foodRecord?.setSelectedUnitKeepWeight(unitName: label)
    }

}

extension FoodEditorView: UITextFieldDelegate {

    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        let kbToolBarView = UIToolbar.init(frame: CGRect(x: 0, y: 0, width: frame.size.width, height: 44))
        let kbSpacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace,
                                       target: nil, action: nil)
        let bottonOk = UIBarButtonItem(title: "OK".localized, style: .plain, target: self,
                                       action: #selector(closeKeyBoard(barButtonItem:)))
        bottonOk.tag = textField.tag
        kbToolBarView.items = [kbSpacer, bottonOk, kbSpacer]
        kbToolBarView.tintColor = .white
        kbToolBarView.barTintColor = UIColor(named: "CustomBase", in: bundlePod, compatibleWith: nil)
        textField.inputAccessoryView = kbToolBarView
        // frame.origin.y -= 180
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
        // frame.origin.y += 180
        if let textGerman = textField.text {
            let text = textGerman.replacingOccurrences(of: ",", with: ".")
            if let quantity = Double(text), var tempfoodRecord = foodRecord {
                _ = tempfoodRecord.setFoodRecordServing(unit: tempfoodRecord.selectedUnit, quantity: quantity)
                foodRecord = tempfoodRecord
            }
        }
        tableView.reloadData()
    }

}

extension FoodEditorView { // Cells

    func getFoodHeaderFullTableViewCell(cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "FoodHeaderFullTableViewCell",
                                                       for: indexPath) as? FoodHeaderFullTableViewCell,
              let foodRecord = foodRecord else {
            return UITableViewCell()
        }

        let foodHeader = FoodHeaderModel(foodRecord: foodRecord)
        cell.iconScannedAmount.isHidden = true // will be checked below
        cell.labelName.text = foodHeader.labelName
        cell.labelServing.text = foodHeader.labelServing
        cell.calories.text = foodHeader.calories
        cell.carbs.text = foodHeader.carbs
        cell.protein.text = foodHeader.protein
        cell.fat.text = foodHeader.fat

        cell.labelCal.text = foodHeader.labelCal
        cell.labelCarbs.text = foodHeader.labelCarbs
        cell.labelProtein.text = foodHeader.labelProtein
        cell.lableFat.text = foodHeader.lableFat
        // cell.imageFood.image = foodRecord.icon
        cell.passioIDForCell = foodRecord.passioID
        cell.passioIDForCell = foodRecord.passioID
        cell.imageFood.loadPassioIconBy(passioID: foodRecord.passioID,
                                        entityType: foodRecord.entityType) { passioIDForImage, image in
            if passioIDForImage == cell.passioIDForCell {
                DispatchQueue.main.async {
                    cell.imageFood.image = image
                }
            }
        }
        cell.imageFood.isUserInteractionEnabled = false
        let titleRecognizer = UITapGestureRecognizer(target: self, action: #selector(renameFoodRecordAlert))
        cell.labelName.addGestureRecognizer(titleRecognizer)
        cell.imageFood.roundMyCorner()
        cell.buttonShowAmounts.isHidden = showAmount
        cell.buttonShowAmounts.addTarget(self, action: #selector(toogleShowAmounts), for: .touchUpInside)
        cell.selectionStyle = .none
        cell.insetBackground.backgroundColor = UIColor(named: Custom.insetBackgroundColor,
                                                       in: bundlePod, compatibleWith: nil)
        if foodRecord.selectedUnit == foodRecord.scannedUnitName {
            cell.iconScannedAmount.isHidden = false
        }
        return cell
    }

    func getFoodHeaderMiniTableViewCell(cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "FoodHeaderMiniTableViewCell",
                                                       for: indexPath) as? FoodHeaderMiniTableViewCell,
              let foodRecord = foodRecord else {
            return UITableViewCell()
        }
        let foodHeader = FoodHeaderModel(foodRecord: foodRecord)
        cell.labelName.text = foodHeader.labelName
        cell.labelServing.text = foodHeader.labelServing
        cell.calories.text = foodHeader.calories
        cell.carbs.text = foodHeader.carbs
        cell.protein.text = foodHeader.protein
        cell.fat.text = foodHeader.fat

        cell.labelCal.text = foodHeader.labelCal
        cell.labelCarbs.text = foodHeader.labelCarbs
        cell.labelProtein.text = foodHeader.labelProtein
        cell.lableFat.text = foodHeader.lableFat

        cell.labelName.textColor = .black
        cell.labelServing.textColor = .black
        cell.calories.textColor = .black
        cell.carbs.textColor = .black
        cell.protein.textColor = .black
        cell.fat.textColor = .black

        cell.labelCal.textColor = .black
        cell.labelCarbs.textColor = .black
        cell.labelProtein.textColor = .black
        cell.lableFat.textColor = .black

        // cell.imageFood.image = foodRecord.icon
        cell.passioIDForCell = foodRecord.passioID
        cell.imageFood.loadPassioIconBy(passioID: foodRecord.passioID,
                                        entityType: foodRecord.entityType) { passioIDForImage, image in
            if passioIDForImage == cell.passioIDForCell {
                DispatchQueue.main.async {
                    cell.imageFood.image = image
                }
            }
        }
        cell.imageFood.isUserInteractionEnabled = true

        cell.imageFood.roundMyCorner()
        cell.selectionStyle = .none
        cell.insetBackground.backgroundColor = UIColor(named: Custom.insetBackgroundColor,
                                                       in: bundlePod, compatibleWith: nil)
        if foodRecord.selectedUnit == foodRecord.scannedUnitName {
            cell.buttonAmount.isHidden = false
        } else {
            cell.buttonAmount.isHidden = true
        }
        return cell
    }

    func getFoodHeaderMicroTableViewCell(cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "FoodHeaderMicroTableViewCell",
                                                       for: indexPath) as? FoodHeaderMicroTableViewCell else {
            return UITableViewCell()
        }

        cell.buttonAmount.isHidden = true
        cell.labelRescan.isHidden = true
        cell.labelGrams.text = ""

        if let foodRecord = foodRecord {
            cell.rotateSpinner =  false
            // cell.imageFood.image = foodRecord.icon

            var nutritionName = ""
            if let passioID = foodRecord.nutritionalPassioID,
               let nName = passioSDK.lookupPassioIDAttributesFor(passioID: passioID)?.name {
                nutritionName  = nName
            } else if foodRecord.nutritionalPassioID == foodRecord.nutritionalPassioID,
                      let nName = foodRecord.visualName?.capitalized {
                nutritionName = nName
            }
            cell.labelName.text = "Detected: " + (foodRecord.visualName?.capitalized ?? "") + "\nNutrition: \(nutritionName.capitalized)"
            if foodRecord.selectedUnit == foodRecord.scannedUnitName { // }, foodRecord.computedWeight.value > 10 {
                cell.labelGrams.text = "Scannned Amount: \(Int(foodRecord.computedWeight.value)) g"
                cell.buttonAmount.isHidden = false
                cell.labelRescan.isHidden = false
                cell.buttonAmount.addTarget(self, action: #selector(rescanVolume), for: .touchUpInside)
            }
            cell.passioIDForCell = foodRecord.passioID
            cell.imageFood.loadPassioIconBy(passioID: foodRecord.passioID,
                                            entityType: foodRecord.entityType) { passioIDForImage, image in
                // print(" passioIDForImage == foodRecord.passioID  \(passioIDForImage) == \(foodRecord.passioID)" )
            if passioIDForImage == cell.passioIDForCell {
                    DispatchQueue.main.async {
                        cell.imageFood.image = image
                    }
                }
            }

        } else {
            cell.passioIDForCell = nil
            cell.rotateSpinner = true
            cell.labelName.text = "Scanning for food".localized
        }
        cell.insetBackground.backgroundColor = .clear
        cell.labelName.textColor = .black
        cell.labelGrams.textColor = .black
        let swipe = UISwipeGestureRecognizer(target: self, action: #selector(addToLog))
        swipe.direction = .right
        cell.addGestureRecognizer(swipe)
        let swipeL = UISwipeGestureRecognizer(target: self, action: #selector(cleanPersonalizatio))
        swipeL.direction = .left
        cell.addGestureRecognizer(swipeL)
        cell.tag = 0 // for swipe tag
        cell.selectionStyle = .none
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

    @objc func rescanVolume() {
        delegate?.rescanVolume()
        print("rescanVolume()")
    }

    @objc func swipeFoodHearder() {
        print("swipeFoodHearder")
    }

    @objc func cleanPersonalizatio() {
        print("swipe letft")
        if let passioID = foodRecord?.visualPassioID {
            passioSDK.cleanPersonalizationForVisual(passioID: passioID )
            delegate?.animateMicroTotheLeft()
        }
    }

    func getAmountSliderFullTableViewCell(indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "AmountSliderFullTableViewCell",
                                                       for: indexPath) as? AmountSliderFullTableViewCell else {
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
        cell.labelAmount.textColor = .black
        cell.buttonUnits.setTitle(newTitle, for: .normal)
        cell.buttonUnits.tag = indexPath.row
        cell.buttonUnits.addTarget(self, action: #selector(changeLabel(sender:)), for: .touchUpInside)
        cell.buttonUnits.backgroundColor = UIColor(named: "PassioMedContrast",
                                                   in: bundlePod, compatibleWith: nil)
        cell.sliderAmount.addTarget(self, action: #selector(sliderAmountValueDidChange(sender:)), for: .valueChanged)
        cell.tag = indexPath.row
        cell.buttonHideAmount.isHidden = !showAmount
        cell.buttonHideAmount.addTarget(self, action: #selector(toogleShowAmounts), for: .touchUpInside)
        cell.selectionStyle = .none

        cell.insetBackground.backgroundColor = UIColor(named: Custom.insetBackgroundColor,
                                                       in: bundlePod, compatibleWith: nil)
        return cell
    }

    func getAmountSliderMiniTableViewCell(indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "AmountSliderMiniTableViewCell",
                                                       for: indexPath) as? AmountSliderMiniTableViewCell else {
            return UITableViewCell()
        }
        let (quantity, unitName, weight) = getAmountsforCell(tableRowOrCollectionTag: indexPath.row,
                                                             slider: cell.sliderAmount)
        let textAmount = quantity == Double(Int(quantity)) ? String(Int(quantity)) :
            String(quantity.roundDigits(afterDecimal: 2))
        cell.textAmount.text = textAmount
        cell.textAmount.textColor = .black
        cell.textAmount.backgroundColor = UIColor(named: "PassioLowContrast",
                                                  in: bundlePod, compatibleWith: nil)
        cell.textAmount.tag = indexPath.row
        cell.textAmount.delegate = self
        cell.labelAmount.text = unitName == "g" ? "" : "(" + weight + " " + "g".localized + ") "
        let newTitle = " " + unitName + " " // title == "Gram" ? title : title + " (" + weight + " " + "Gram") + ") "
        cell.buttonUnits.setTitle(newTitle, for: .normal)
        cell.buttonUnits.tag = indexPath.row

        cell.buttonUnits.setTitleColor(.black, for: .normal)
        cell.buttonUnits.addTarget(self, action: #selector(changeLabel(sender:)), for: .touchUpInside)
        let passioMed = UIColor(named: "PassioMedContrast",
                                in: bundlePod, compatibleWith: nil)
        cell.buttonUnits.backgroundColor = passioMed
        cell.sliderAmount.addTarget(self, action: #selector(sliderAmountValueDidChange(sender:)), for: .valueChanged)
        cell.tag = indexPath.row
        //        cell.buttonHideAmount.isHidden = !showAmount
        //        cell.buttonHideAmount.addTarget(self, action: #selector(toogleShowAmounts), for: .touchUpInside)
        cell.selectionStyle = .none
        cell.insetBackground.backgroundColor = UIColor(named: Custom.insetBackgroundColor,
                                                       in: bundlePod, compatibleWith: nil)
        return cell
    }

    func getAmountQuickMiniTableViewCell(indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "AmountQuickMiniTableViewCell",
                                                       for: indexPath) as? AmountQuickMiniTableViewCell else {
            return UITableViewCell()
        }
        cell.tag = IndexForCollections.amountQuickMini.rawValue
        cell.selectionStyle = .none
        cell.insetBackground.backgroundColor = UIColor(named: Custom.insetBackgroundColor,
                                                       in: bundlePod, compatibleWith: nil)
        return cell
    }

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

    func getAlternativesMicroTableViewCell(indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "AlternativesMicroTableViewCell",
                                                       for: indexPath) as? AlternativesMicroTableViewCell else {
            return UITableViewCell()
        }
        cell.tag = IndexForCollections.alternatives.rawValue
        cell.collectionViewHeight.constant = 44
        cell.selectionStyle = .none
        cell.insetBackground.backgroundColor = .clear
        return cell
    }

    func getIngredientAddTableViewCell(indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "IngredientAddTableViewCell",
                                                       for: indexPath) as? IngredientAddTableViewCell else {
            return UITableViewCell()
        }
        cell.titleLabel.text = "Ingredients".localized
        cell.buttonAddIngredients.addTarget(self, action: #selector(addIngredients), for: .touchUpInside)
        cell.selectionStyle = .none
        return cell
    }

    @objc func addIngredients() {
        delegate?.foodEditorSearchText()
    }

    func getIngredientHeaderTableViewCell(indexPath: IndexPath) -> UITableViewCell {

//        var indexForIngredient = indexPath.row - rowBeforeIngrediants - 1
//        indexForIngredient = showAlternativesRow ? indexForIngredient : indexForIngredient - 1

        let numbertoJump = (foodRecord?.isOpenFood ?? false) ? 2 : 1
        let indexForIngredient = indexPath.row - rowsBeforeIngrediants - numbertoJump

        guard let cell = tableView.dequeueReusableCell(withIdentifier: "IngredientHeaderTableViewCell",
                                                       for: indexPath) as? IngredientHeaderTableViewCell else {
            return UITableViewCell()
        }
        guard let foodRecord = foodRecord,
              foodRecord.ingredients.count > indexForIngredient else {
            return IngredientHeaderTableViewCell()
        }
        // print("indexForIngredient", indexForIngredient )
        let ingredient = foodRecord.ingredients[indexForIngredient]
        cell.labelName.text = ingredient.name.capitalized
        let quantity = ingredient.selectedQuantity
        let unitName = ingredient.selectedUnit.capitalized
        let weight = String(Int(ingredient.computedWeight.value))
        let textAmount = quantity == Double(Int(quantity)) ? String(Int(quantity)) :
            String(quantity.roundDigits(afterDecimal: 2))
        let weightText = unitName == "g" ? "" : "(" + weight + " " + "g".localized + ") "
        cell.labelServing.text = textAmount + " " + unitName + " " + weightText

        var calStr = "0"
        if let cal = ingredient.totalCalories?.value, 0 < cal, cal < 1e6 {
            calStr = String(Int(cal))
        }
        cell.labelCalories.text = "Calories".localized + ": " +  calStr
        cell.passioIDForCell = ingredient.passioID
        cell.imageFood.loadPassioIconBy(passioID: ingredient.passioID,
                                        entityType: ingredient.entityType) { passioIDForImage, image in
            if passioIDForImage == cell.passioIDForCell {
                DispatchQueue.main.async {
                    cell.imageFood.image = image
                }
            }
        }
        cell.tag = indexPath.row
        cell.imageFood.roundMyCorner()
        cell.selectionStyle = .none
        cell.insetBackground.backgroundColor = UIColor(named: Custom.insetBackgroundColor,
                                                       in: bundlePod, compatibleWith: nil)
        cell.labelTime.text = ""// foodRecord.mealLabel.rawValue
        cell.contentView.roundMyCornerWith(radius: Custom.buttonCornerRadius)
        return cell
    }

    func getAlternativeBrowserTableViewCell(indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "AlternativeBrowserTableViewCell",
                                                       for: indexPath) as? AlternativeBrowserTableViewCell else {
            return UITableViewCell()
        }
        cell.buttonSelectAlternative.isHidden = foodRecord != nil ? false : true
        cell.buttonSelectAlternative.addTarget(self, action: #selector(startNutritionBrowser), for: .touchUpInside)
        cell.buttonSelectAlternative.roundMyCornerWith(radius: Custom.buttonCornerRadius)
        cell.roundMyCornerWith(radius: Custom.insetBackgroundRadius)
        cell.contentView.backgroundColor = UIColor(named: Custom.insetBackgroundColor,
                                                       in: bundlePod, compatibleWith: nil)
        return cell
    }

    func getMealSelectionCell(indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(withIdentifier: "MealSelectionTableViewCell",
                                                       for: indexPath) as? MealSelectionTableViewCell else {
            return UITableViewCell()
        }

        if let meal = foodRecord?.mealLabel {
            cell.setMealSelection(meal)
        }

        cell.delegate = self
        cell.insetBackgroundView.backgroundColor = UIColor(named: Custom.insetBackgroundColor,
                                                       in: bundlePod, compatibleWith: nil)
        return cell
    }

    @objc func startNutritionBrowser() {
        if let foodRecord = foodRecord {
            delegate?.startNutritionBrowser(foodRecord: foodRecord)
        }
    }
}

extension FoodEditorView: MealSelectionDelegate {

    func didChangeMealSelection(selection: MealLabel) {
        foodRecord?.mealLabel = selection
    }
}
