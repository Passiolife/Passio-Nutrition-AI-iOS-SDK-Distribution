//
//  MultipleTableViewCell.swift
//  BaseApp
//
//  Created by zvika on 2/19/20.
//  Copyright © 2023 Passio Inc. All rights reserved.
//

import UIKit

class MultipleTableViewCell: UITableViewCell {

    @IBOutlet weak var foodName: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var imageFood: UIImageView!
    @IBOutlet weak var buttonCheckBox: UIButton!
    @IBOutlet weak var insetBackground: UIView!
    var passioIDForCell: PassioID?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        insetBackground.roundMyCornerWith(radius: Custom.insetBackgroundRadius)
        imageFood.roundMyCorner()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
