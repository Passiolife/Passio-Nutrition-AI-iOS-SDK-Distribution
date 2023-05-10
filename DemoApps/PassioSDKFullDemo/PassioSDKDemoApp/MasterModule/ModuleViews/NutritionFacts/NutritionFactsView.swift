//
//  NutritionFactsView.swift
//  BaseApp
//
//  Created by zvika on 2/25/20.
//  Copyright © 2023 Passio Inc. All rights reserved.
//

import UIKit
#if canImport(PassioNutritionAISDK)
import PassioNutritionAISDK
#endif

protocol NutritionFactsViewDelegate: AnyObject {
    func userCancelNutritionFacts()
    func userPressedNext(withName name: String)
}

class NutritionFactsView: UIView {

    weak var delegate: NutritionFactsViewDelegate?
    var nfc: PassioNutritionFacts?
    let bundlePod =  PassioInternalConnector.shared.bundleForModule

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var buttonCancel: UIButton!
    @IBOutlet weak var buttonClear: UIButton!
    @IBOutlet weak var buttonNext: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.allowsSelection = true
        tableView.estimatedRowHeight = 200
        NutritionCells.allCases.forEach {
            let cellName = $0.rawValue.capitalizingFirst()
            let cell = UINib(nibName: cellName, bundle: bundlePod)
            tableView.register(cell, forCellReuseIdentifier: cellName)
        }

        //        let image = UIImage(named: "bttn_bg",
        //                            in: bundlePod,
        //                            compatibleWith: nil)
        //        buttonCancel.setBackgroundImage(image, for: .normal)
        buttonCancel.setTitle("Cancel".localized, for: .normal)
        buttonCancel.roundMyCornerWith(radius: Custom.buttonCornerRadius)
        //        buttonClear.setBackgroundImage(image, for: .normal)
        buttonClear.setTitle("Clear".localized, for: .normal)
        buttonClear.roundMyCornerWith(radius: Custom.buttonCornerRadius)
        //        buttonNext.setBackgroundImage(image, for: .normal)
        buttonNext.setTitle("Next".localized, for: .normal)
        buttonNext.setTitleColor(.gray, for: .disabled)
        // buttonNext.setTitleColor(UIColor(named: "CustomeBase"), for: .normal)
        buttonNext.roundMyCornerWith(radius: Custom.buttonCornerRadius)
        buttonNext.isEnabled = false
    }

    @IBAction func cancelNutritionFacts(_ sender: UIButton) {
        delegate?.userCancelNutritionFacts()
    }

    @IBAction func clearTable(_ sender: UIButton) {
        nfc?.clearAll()
        reloadNFCView()
    }

    @IBAction func goNext(_ sender: UIButton) {
        renameFoodRecordAlert()
    }

    func reloadNFCView() {
        buttonNext.isEnabled = nfc?.isCompleted ?? false
        tableView.reloadData()
    }

    func renameFoodRecordAlert() {
        let alertName = UIAlertController(title: "Name your food".localized, message: nil, preferredStyle: .alert)
        alertName.addTextField { (textField) in
            textField.clearButtonMode = .always
        }
        let save = UIAlertAction(title: "Save".localized, style: .default) { (_) in
            let firstTextField = alertName.textFields![0] as UITextField
            if let name = firstTextField.text, name.count >= 1 {
                self.delegate?.userPressedNext(withName: name)
            } else {
                // do nothing here
            }
        }
        let cancel = UIAlertAction(title: "Cancel".localized, style: .cancel) { (_) in
        }
        alertName.addAction(save)
        alertName.addAction(cancel)
        self.findViewController()?.present(alertName, animated: true)
    }

}

extension NutritionFactsView: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return nfc == nil ? 0 :6
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let nfc = nfc else { return UITableViewCell() }
        switch indexPath.row {
        case 0:
            let cellID = NutritionCells.nutritionTitleTableViewCell.rawValue.capitalizingFirst()
            guard let cell = tableView.dequeueReusableCell(withIdentifier: cellID,
                                                           for: indexPath) as? NutritionTitleTableViewCell else {
                return UITableViewCell()
            }
            cell.labelTitle.text = nfc.titleNutritionFacts
            cell.selectionStyle = .none
            return cell
        case 1: // service size
            let cellID = NutritionCells.nutritionDetailTableViewCell.rawValue.capitalizingFirst()
            guard let cell = tableView.dequeueReusableCell(withIdentifier: cellID,
                                                           for: indexPath) as? NutritionDetailTableViewCell else {
                return UITableViewCell()
            }
            cell.lableNutrient.text = nfc.titleServingSize
            cell.valeuNutrient.text = nfc.servingSizeText
            return cell
        case 2: // Calories
            let cellID = NutritionCells.nutritionDetailTableViewCell.rawValue.capitalizingFirst()
            guard let cell = tableView.dequeueReusableCell(withIdentifier: cellID,
                                                           for: indexPath) as?  NutritionDetailTableViewCell else {
                return UITableViewCell()
            }
            cell.lableNutrient.text = nfc.titleCalories
            cell.valeuNutrient.text = nfc.caloriesText
            return cell
        case 3: // Fat
            let cellID = NutritionCells.nutritionDetailTableViewCell.rawValue.capitalizingFirst()
            guard let cell = tableView.dequeueReusableCell(withIdentifier: cellID,
                                                           for: indexPath) as? NutritionDetailTableViewCell else {
                return UITableViewCell()
            }
            cell.lableNutrient.text = nfc.titleTotalFat
            cell.valeuNutrient.text = nfc.fatText
            return cell
        case 4: // Carbs
            let cellID = NutritionCells.nutritionDetailTableViewCell.rawValue.capitalizingFirst()
            guard let cell = tableView.dequeueReusableCell(withIdentifier: cellID,
                                                           for: indexPath) as? NutritionDetailTableViewCell else {
                return UITableViewCell()
            }
            cell.lableNutrient.text = nfc.titleTotalCarbs
            cell.valeuNutrient.text = nfc.carbsText
            return cell
        case 5: // Protein
            let cellID = NutritionCells.nutritionDetailTableViewCell.rawValue.capitalizingFirst()
            guard let cell = tableView.dequeueReusableCell(withIdentifier: cellID,
                                                           for: indexPath) as? NutritionDetailTableViewCell else {
                return UITableViewCell()
            }
            cell.lableNutrient.text = nfc.titleProtein
            cell.valeuNutrient.text = nfc.proteinText
            return cell
        default:
            let cellID = NutritionCells.nutritionDetailTableViewCell.rawValue.capitalizingFirst()
            guard let cell = tableView.dequeueReusableCell(withIdentifier: cellID,
                                                           for: indexPath) as? NutritionDetailTableViewCell else {
                return UITableViewCell()
            }
            return cell
        }
    }

    enum NutritionCells: String, CaseIterable {
        case
        nutritionHeaderTableViewCell,
        nutritionTitleTableViewCell,
        nutritionDetailTableViewCell
    }

}
extension NutritionFactsView: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        nfc?.isManuallyEdited = true
        nameRow(atIndex: indexPath)
    }

    func nameRow(atIndex: IndexPath) {

        tableView.deselectRow(at: atIndex, animated: true)
        if atIndex.row == 1 {
            tripleField()
        } else {
            singleField(atIndex: atIndex)
        }
    }

    func tripleField() {
        guard let nfc = nfc else { return }
        var message = "Automatic detection was stopped, all values can be edited manually".localized
        message = "\(message)\nQuntity:\nUnit name:\nGrams:"
        let tripleAlert = UIAlertController(title: "Service Sizes".localized,
                                            message: message,
                                            preferredStyle: .alert)

        tripleAlert.addTextField { (textField) in
            textField.text =  String(nfc.servingSizeQuantity)
            textField.tag = 1
            textField.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: .editingChanged)
        }

        tripleAlert.addTextField { (textField) in
            textField.text =  nfc.servingSizeUnitName ?? "Unit name"
            textField.tag = 2
            textField.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: .editingChanged)
        }

        tripleAlert.addTextField { (textField) in
            textField.text =  String(nfc.servingSizeGram ?? 0.0)
            textField.tag = 3
            textField.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: .editingChanged)
        }

        let ok = UIAlertAction(title: "OK".localized, style: .default) { (_) in }

        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (_) in }
        tripleAlert.addAction(ok)
        tripleAlert.addAction(cancel)
        self.findViewController()?.present(tripleAlert, animated: true)

    }

    @objc private func textFieldDidChange(_ field: UITextField) {
        guard let nfc = nfc,
              let text = field.text,
              text.count > 0 else {
                  return
              }
        switch field.tag {
        case 1:
            if let value = Double(text) {
                nfc.servingSizeQuantity = value
            }
        case 2:
            nfc.servingSizeUnitName = text
        case 3:
            if let value = Double(text) {
                nfc.servingSizeGram = value
            }
        default:
            return
        }
    }

    func singleField (atIndex: IndexPath) {
        guard let nfc = nfc else { return }
        let (name, value) = getNamAndValue(atIndex: atIndex)
        let message = "Automatic detection was stopped, all values can be edited manually".localized
        let alertName = UIAlertController(title: name, message: message, preferredStyle: .alert)
        alertName.addTextField { (textField) in
            textField.keyboardType = .numberPad
            textField.clearButtonMode = .always
            textField.placeholder = String(value)
        }
        let save = UIAlertAction(title: "Save".localized, style: .default) { (_) in
            let firstTextField = alertName.textFields![0] as UITextField
            if let name = firstTextField.text, name.count >= 1 {
                switch atIndex.row {
                case 2:
                    nfc.calories = Double(name) ?? 0
                case 3:
                    nfc.fat = Double(name) ?? 0
                case 4:
                    nfc.carbs = Double(name) ?? 0
                case 5:
                    nfc.protein = Double(name) ?? 0
                default:
                    break
                }
            }
            self.reloadNFCView()
        }
        let cancel = UIAlertAction(title: "Cancel".localized, style: .cancel) { (_) in
        }
        alertName.addAction(save)
        alertName.addAction(cancel)
        self.findViewController()?.present(alertName, animated: true)
    }

    func getNamAndValue(atIndex: IndexPath) -> (name: String, value: Double) {
        guard let nfc = nfc else { return("", 0) }
        var name: String
        var value: Double
        switch atIndex.row {
        case 2:
            name = nfc.titleCalories
            value = nfc.calories ?? 0
        case 3:
            name = nfc.titleTotalFat
            value = nfc.fat ?? 0
        case 4:
            name = nfc.titleTotalCarbs
            value = nfc.carbs ?? 0
        case 5:
            name = nfc.titleProtein
            value = nfc.protein ?? 0
        default:
            name = "Something went wrong".localized
            value = 0
        }
        return(name, value)
    }

}
