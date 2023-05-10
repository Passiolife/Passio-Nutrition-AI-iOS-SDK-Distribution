//
//  FoodHeaderMicroTableViewCell.swift
//  PassioPassport
//
//  Created by zvika on 2/14/19.
//  Copyright © 2022 Passiolife Inc. All rights reserved.
//

import UIKit

class FoodHeaderMicroTableViewCell: UITableViewCell {

    @IBOutlet weak var imageFood: UIImageView!
    @IBOutlet weak var labelName: UILabel!
    @IBOutlet weak var labelGrams: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var insetBackground: UIView!
    @IBOutlet weak var buttonAmount: UIButton!
    @IBOutlet weak var labelRescan: UIStackView!

    override func awakeFromNib() {
        super.awakeFromNib()
        buttonAmount.setTitle("", for: .normal)
        buttonAmount.isHidden = true
        labelRescan.isHidden = true
    }

    func roundSpinner(startRotation: Bool) {
        if startRotation {
            imageFood.image = UIImage(named: "spinner_circles",
                                      in: PassioInternalConnector.shared.bundleForModule, compatibleWith: nil)
            imageFood.startRotating(duration: 3)
        } else {
            imageFood.image = nil
            imageFood.stopRotating()
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        imageFood.roundMyCorner()
        insetBackground.roundMyCornerWith(radius: Custom.insetBackgroundRadius)
    }

}
