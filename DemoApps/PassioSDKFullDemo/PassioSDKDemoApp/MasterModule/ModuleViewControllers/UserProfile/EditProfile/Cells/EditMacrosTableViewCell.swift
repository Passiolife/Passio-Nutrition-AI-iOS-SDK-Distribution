//
//  EditMacrosTableViewCell.swift
//  BaseApp
//
//  Created by zvika on 1/11/21.
//  Copyright © 2023 Passio Inc. All rights reserved.
//

import UIKit

class EditMacrosTableViewCell: UITableViewCell {
    @IBOutlet weak var cellTitle: UILabel!

    @IBOutlet weak var carbsTitle: UILabel!
    @IBOutlet weak var proteinTitle: UILabel!
    @IBOutlet weak var fatTitle: UILabel!

    @IBOutlet weak var carbsPercent: UILabel!
    @IBOutlet weak var proteinPercent: UILabel!
    @IBOutlet weak var fatPercent: UILabel!

    @IBOutlet weak var carbsGrams: UILabel!
    @IBOutlet weak var proteinGrams: UILabel!
    @IBOutlet weak var fatGrams: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
