//
//  FoodHeaderMiniTableViewCell.swift
//  PassioPassport
//
//  Created by zvika on 2/14/19.
//  Copyright © 2023 Passiolife Inc. All rights reserved.
//

import UIKit

class FoodHeaderMiniTableViewCell: UITableViewCell {

    @IBOutlet weak var imageFood: UIImageView!
    @IBOutlet weak var labelName: UILabel!
    @IBOutlet weak var labelServing: UILabel!

    @IBOutlet weak var calories: UILabel!
    @IBOutlet weak var carbs: UILabel!
    @IBOutlet weak var protein: UILabel!
    @IBOutlet weak var fat: UILabel!

    @IBOutlet weak var labelCal: UILabel!
    @IBOutlet weak var labelCarbs: UILabel!
    @IBOutlet weak var labelProtein: UILabel!
    @IBOutlet weak var lableFat: UILabel!
    @IBOutlet weak var insetBackground: UIView!

    @IBOutlet weak var buttonAmount: UIButton!
    var passioIDForCell: PassioID?

    override func awakeFromNib() {
        super.awakeFromNib()
        buttonAmount.setTitle("", for: .normal)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        imageFood.roundMyCorner()
        insetBackground.roundMyCornerWith(radius: Custom.insetBackgroundRadius)
    }

}
