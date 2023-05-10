//
//  NutritionDetailTableViewCell.swift
//  BaseApp
//
//  Created by zvika on 2/25/20.
//  Copyright © 2023 Passio Inc. All rights reserved.
//

import UIKit

class NutritionDetailTableViewCell: UITableViewCell {

    @IBOutlet weak var lableNutrient: UILabel!
    @IBOutlet weak var valeuNutrient: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }

}
