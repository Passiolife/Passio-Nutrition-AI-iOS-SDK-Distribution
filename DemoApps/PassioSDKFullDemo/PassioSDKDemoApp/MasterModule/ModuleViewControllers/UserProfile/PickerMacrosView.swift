//
//  PickerMacroView.swift
//  PassioPassport
//
//  Created by zvika on 2/28/19.
//  Copyright © 2023 Passiolife Inc. All rights reserved.
//

import UIKit

protocol PickerMacroViewDelegate: AnyObject {
    func pickerSelected(modelMacros: Macros?, myView: PickerMacrosView)
}

class PickerMacrosView: UIView {

    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var carbsGrams: UILabel!
    @IBOutlet weak var proteinGrams: UILabel!
    @IBOutlet weak var fatGrams: UILabel!
    @IBOutlet weak var picker: UIPickerView!
    @IBOutlet weak var buttonSave: UIButton!
    @IBOutlet weak var buttonCancel: UIButton!

    var title: String?
    var indexPath: IndexPath?
    var modelMacros = Macros(caloriesTarget: 2100, carbsPercent: 0, proteinPercent: 0, fatPercent: 0)

    weak var delegate: PickerMacroViewDelegate?

    override func layoutSubviews() {
        super.layoutSubviews()

        self.roundMyCornerWith(radius: 20)
        picker.delegate = self
        picker.dataSource = self
        labelTitle.text = "Macro Targets"
//        let image = UIImage(named: "bttn_bg",
//                            in: PassioInternalConnector.shared.bundleForModule,
//                            compatibleWith: nil)
//        buttonSave.setBackgroundImage(image, for: .normal)
        buttonSave.setTitle("OK".localized, for: .normal)
        buttonSave.roundMyCornerWith(radius: Custom.buttonCornerRadius)
//        buttonCancel.setBackgroundImage(image, for: .normal)
        buttonCancel.setTitle("Cancel".localized, for: .normal)
        buttonCancel.roundMyCornerWith(radius: Custom.buttonCornerRadius)
        picker.setValue(UIColor.white, forKeyPath: "textColor")
        setUIToMatchMacros()
    }

    private func setUIToMatchMacros() {
        picker.selectRow(modelMacros.carbsPercent,
                         inComponent: 0, animated: true)
        carbsGrams.text = "\(modelMacros.carbsGrams) g"
        picker.selectRow(modelMacros.proteinPercent,
                         inComponent: 1, animated: true)
        proteinGrams.text = "\(modelMacros.proteinGrams) g"
        picker.selectRow(modelMacros.fatPercent,
                         inComponent: 2, animated: true)
        fatGrams.text = "\(modelMacros.fatGrams) g"
    }

    @IBAction func cancel(_ sender: UIButton) {
        delegate?.pickerSelected(modelMacros: nil, myView: self)
    }

    @IBAction func save(_ sender: UIButton) {
        delegate?.pickerSelected(modelMacros: modelMacros, myView: self)
    }

}

extension PickerMacrosView: UIPickerViewDataSource {

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
            return 3
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
             101
    }

}

extension PickerMacrosView: UIPickerViewDelegate {

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch component {
        case 0:
            modelMacros.set(carbs: row)
        case 1:
            modelMacros.set(protein: row)
        case 2:
            modelMacros.set(fat: row)
        default:
            print("Something is not right")
        }
        setUIToMatchMacros()
    }

    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let pickerLabel = UILabel()
        pickerLabel.textColor = .black
        pickerLabel.text = "\(row) %" // String(modelOneComp?[row] ?? 0)
        pickerLabel.font = UIFont(name: "Avenir-Medium", size: 20)
        pickerLabel.textAlignment = NSTextAlignment.center
        return pickerLabel
    }

}
