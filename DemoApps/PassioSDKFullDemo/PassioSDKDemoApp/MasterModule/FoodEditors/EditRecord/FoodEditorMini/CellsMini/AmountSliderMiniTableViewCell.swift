//
//  AmountSliderMiniTableViewCell.swift
//  PassioPassport
//
//  Created by zvika on 2/1/19.
//  Copyright © 2023 Passiolife Inc. All rights reserved.
//

import UIKit

class AmountSliderMiniTableViewCell: UITableViewCell {

    @IBOutlet weak var labelAmount: UILabel!
    @IBOutlet weak var sliderAmount: UISlider!
    @IBOutlet weak var buttonUnits: UIButton!
    @IBOutlet weak var textAmount: UITextField!
    @IBOutlet weak var insetBackground: UIView!

    override func layoutSubviews() {
        super.layoutSubviews()
        buttonUnits.roundMyCornerWith(radius: Custom.buttonCornerRadius)
        insetBackground.roundMyCornerWith(radius: Custom.insetBackgroundRadius, upper: true, down: false)
    }

}
