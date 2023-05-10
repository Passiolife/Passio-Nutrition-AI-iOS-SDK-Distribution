//
//  DateSelectorUIView.swift
//  Passio App Module
//
//  Created by zvika on 2/13/19.
//  Copyright © 2023 Passiolife Inc. All rights reserved.
//

import UIKit

protocol DateSelectorUIViewDelegate: AnyObject {
    func dateFromPicker(date: Date)
    func removeDateSelector(remove: Bool)
}

class DateSelectorUIView: UIView {

    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var buttonToday: UIButton!
    @IBOutlet weak var buttonOK: UIButton!

    var dateForPicker: Date?
    weak var delegate: DateSelectorUIViewDelegate?

    public init(frame: CGRect, date: Date) {
        super.init(frame: frame)
        dateForPicker = date
    }

    override func layoutSubviews() {
        if let date = dateForPicker {
            datePicker?.date = date
        }
        if #available(iOS 13.4, *) {
            datePicker?.preferredDatePickerStyle = .wheels
            datePicker.setValue(UIColor.black, forKeyPath: "textColor")
            datePicker.setValue(false, forKeyPath: "highlightsToday")
        }
        datePicker?.maximumDate = Date()
        datePicker.addTarget(self, action: #selector(reportValue), for: .valueChanged)
//
//        let image = UIImage(named: "bttn_bg",
//                            in: PassioInternalConnector.shared.bundleForModule,
//                            compatibleWith: nil)
//        buttonOK?.setBackgroundImage(image, for: .normal)

        buttonOK?.roundMyCornerWith(radius: Custom.buttonCornerRadius)
        buttonOK?.setTitle("OK".localized, for: .normal)
//        buttonToday?.setBackgroundImage(image, for: .normal)
        buttonToday?.roundMyCornerWith(radius: Custom.buttonCornerRadius)
        buttonToday?.setTitle("Today".localized, for: .normal)
    }

    @IBAction func okAndDismiss(_ sender: UIButton) {
        // print ("datePicker.date",datePicker.date)
        delegate?.dateFromPicker(date: datePicker.date)
        delegate?.removeDateSelector(remove: true)
    }

    @IBAction func todayAndDismiss(_ sender: UIButton) {
        datePicker.setDate(Date(), animated: true)
        delegate?.dateFromPicker(date: Date())
        perform(#selector(removeMe), with: nil, afterDelay: 0.4)
    }

    @objc func reportValue() {
        delegate?.dateFromPicker(date: datePicker.date)
    }

    @objc func removeMe() {
        delegate?.removeDateSelector(remove: true)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        //  fatalError("init(coder:) has not been implemented")
    }

}
