//
//  VotingTableViewCell.swift
//  BaseSDK
//
//  Created by zvika on 7/9/20.
//  Copyright © 2023 Passio Inc. All rights reserved.
//

import UIKit

class VotingTableViewCell: UITableViewCell {

    @IBOutlet weak var labelVoting: UILabel!
    @IBOutlet weak var imageCropped: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
