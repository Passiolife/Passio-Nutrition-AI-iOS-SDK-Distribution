//
//  NBGroupTableViewCell.swift
//  BaseApp
//
//  Created by zvika on 3/10/21.
//  Copyright © 2023 Passio Inc. All rights reserved.
//

import UIKit

class NBGroupTableViewCell: UITableViewCell {

    @IBOutlet weak var arrowDown: UIImageView!
    @IBOutlet weak var labelName: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
