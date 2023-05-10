//
//  LabelTableViewCell.swift
//  BaseApp
//
//  Created by zvika on 8/26/20.
//  Copyright © 2023 Passio Inc. All rights reserved.
//

import UIKit

class LabelTableViewCell: UITableViewCell {
    @IBOutlet weak var bmiLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
