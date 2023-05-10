//
//  PickerPopUpView.swift
//  PassioPassport
//
//  Created by zvika on 2/28/19.
//  Copyright © 2023 Passiolife Inc. All rights reserved.
//

import UIKit

protocol PickerPopUpViewDelegate: AnyObject {
    func pickerSelected(compOne: Int?, compTwo: Int?, indexPath: IndexPath?, myView: PickerPopUpView)
}

class PickerPopUpView: UIView {

    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var picker: UIPickerView!
    @IBOutlet weak var buttonSave: UIButton!
    @IBOutlet weak var buttonCancel: UIButton!

    var title: String?
    var modelOneComp = [String]()
    var startingOneComp: Int?
    var modelTwoComp = [String]()
    var startingTwoComp: Int?
    var indexPath: IndexPath?
    weak var delegate: PickerPopUpViewDelegate?

    override func layoutSubviews() {
        super.layoutSubviews()
        self.roundMyCornerWith(radius: 20)
        picker.delegate = self
        picker.dataSource = self
        labelTitle.text = title ?? "NoTitle"
//        let image = UIImage(named: "bttn_bg",
//                            in: PassioInternalConnector.shared.bundleForModule,
//                            compatibleWith: nil)
//        buttonSave.setBackgroundImage(image, for: .normal)
        buttonSave.setTitle("OK".localized, for: .normal)
        buttonSave.roundMyCornerWith(radius: Custom.buttonCornerRadius)
//        buttonCancel.setBackgroundImage(image, for: .normal)
        buttonCancel.setTitle("Cancel".localized, for: .normal)
        buttonCancel.roundMyCornerWith(radius: Custom.buttonCornerRadius)
        if let one = startingOneComp {
            picker.selectRow(one, inComponent: 0, animated: true)
        }
        if let two = startingTwoComp {
            picker.selectRow(two, inComponent: 1, animated: true)
        }
        picker.setValue(UIColor.white, forKeyPath: "textColor")
    }

    @IBAction func cancel(_ sender: UIButton) {
        delegate?.pickerSelected(compOne: nil, compTwo: nil, indexPath: indexPath, myView: self)
    }

    @IBAction func save(_ sender: UIButton) {
        if modelTwoComp.isEmpty {
            delegate?.pickerSelected(compOne: picker.selectedRow(inComponent: 0), compTwo: nil, indexPath: indexPath, myView: self)
        } else {
            delegate?.pickerSelected(compOne: picker.selectedRow(inComponent: 0), compTwo: picker.selectedRow(inComponent: 1), indexPath: indexPath, myView: self)
        }
    }

}
extension PickerPopUpView: UIPickerViewDataSource {

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        if modelTwoComp.isEmpty {
            return 1
        } else {
            return 2
        }
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch component {
        case 0:
            return modelOneComp.count
        default:
            return modelTwoComp.count
        }
    }

}

extension PickerPopUpView: UIPickerViewDelegate {

    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let pickerLabel = UILabel()
        pickerLabel.textColor = .black
        pickerLabel.text = "Getthis" // String(modelOneComp?[row] ?? 0)
        pickerLabel.font = UIFont(name: "Avenir-Medium", size: 22)
        pickerLabel.textAlignment = NSTextAlignment.center
        switch component {
        case 0:
            pickerLabel.text = modelOneComp[row]
        default:
            pickerLabel.text = modelTwoComp[row]
        }
        return pickerLabel
    }

}
