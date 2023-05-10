//
//  UnitPicker
//  PassioPassport
//
//  Created by zvika on 4/15/19.
//  Copyright © 2023 Passiolife Inc. All rights reserved.
//

import UIKit

protocol UnitPickerViewDelegate: AnyObject {
    func userSelected(label: String, tableTag: Int)
}

class UnitPickerView: UIView {

    @IBOutlet weak var picker: UIPickerView!
    @IBOutlet weak var buttonSelect: UIButton!

    var labelsForPicker: [String] = []
    var indexForSelectedUnit: Int!
    weak var delegate: UnitPickerViewDelegate?

    override func layoutSubviews() {
        super.layoutSubviews()
        picker.delegate = self
        picker.dataSource = self
        picker.selectRow(indexForSelectedUnit, inComponent: 0, animated: true)
//        let image = UIImage(named: "bttn_bg",
//                            in: PassioInternalConnector.shared.bundleForModule,
//                            compatibleWith: nil)
//        buttonSelect.setBackgroundImage(image, for: .normal)
        buttonSelect.setTitle("Select".localized, for: .normal)
        buttonSelect.roundMyCornerWith(radius: Custom.buttonCornerRadius)
        roundMyCornerWith(radius: 20)
    }

    @IBAction func selectAndClose(_ sender: UIButton) {
        let index = picker.selectedRow(inComponent: 0)
        if labelsForPicker.count > index {
            delegate?.userSelected(label: labelsForPicker[index], tableTag: tag)
        }
        removeFromSuperview()
    }

}

extension UnitPickerView: UIPickerViewDelegate {

    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int,
                    forComponent component: Int, reusing view: UIView?) -> UIView {
        let pickerLabel = UILabel()
        pickerLabel.textColor = .black
        pickerLabel.text = "Getthis" // String(modelOneComp?[row] ?? 0)
        pickerLabel.font = UIFont(name: "Avenir-Medium", size: 20)
        pickerLabel.textAlignment = NSTextAlignment.center
        pickerLabel.text = labelsForPicker[row].capitalized
        return pickerLabel
    }

}

extension UnitPickerView: UIPickerViewDataSource {

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return labelsForPicker.count
    }

}
