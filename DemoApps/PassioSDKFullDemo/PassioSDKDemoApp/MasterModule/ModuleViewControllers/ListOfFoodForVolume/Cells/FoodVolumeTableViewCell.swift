//
//  FoodVolumeTableViewCell.swift
//  Passio App Module
//
//  Created by zvika on 2/12/19.
//  Copyright © 2023 Passiolife Inc. All rights reserved.
//

import UIKit

class FoodVolumeTableViewCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var imageFood: UIImageView!
    @IBOutlet weak var insetBackground: UIView!
    var passioIDForCell: PassioID?

    override func awakeFromNib() {
        super.awakeFromNib()
        insetBackground.roundMyCornerWith(radius: Custom.insetBackgroundRadius)
        imageFood.roundMyCorner()
    }

}
