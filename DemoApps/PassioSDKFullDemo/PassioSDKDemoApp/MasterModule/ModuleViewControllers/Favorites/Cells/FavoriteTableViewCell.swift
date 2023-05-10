//
//  FavoriteTableViewCell.swift
//  Passio App Module
//
//  Created by zvika on 2/12/19.
//  Copyright © 2023 Passiolife Inc. All rights reserved.
//

import UIKit

class FavoriteTableViewCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var nutritionLabel: UILabel!
    @IBOutlet weak var imageFood: UIImageView!
    @IBOutlet weak var insetBackground: UIView!
    @IBOutlet weak var buttonAddToLog: UIButton!
    var passioIDForCell: PassioID?

    override func awakeFromNib() {
        super.awakeFromNib()
        insetBackground.roundMyCornerWith(radius: Custom.insetBackgroundRadius)
    }

}
