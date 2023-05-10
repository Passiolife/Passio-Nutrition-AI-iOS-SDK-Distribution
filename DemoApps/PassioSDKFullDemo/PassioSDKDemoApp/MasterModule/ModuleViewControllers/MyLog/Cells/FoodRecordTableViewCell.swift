//
//  FoodRecordTableViewCell.swift
//  Passio App Module
//
//  Created by zvika on 2/12/19.
//  Copyright © 2023 Passiolife Inc. All rights reserved.
//

import UIKit

class FoodRecordTableViewCell: UITableViewCell {

    @IBOutlet weak var labelName: UILabel!
    @IBOutlet weak var labelServing: UILabel!
    @IBOutlet weak var imageFood: UIImageView!
    @IBOutlet weak var labelTime: UILabel!
    @IBOutlet weak var insetBackground: UIView!
    @IBOutlet weak var sideArrowImage: UIImageView!
    var passioIDForCell: PassioID?

    override func awakeFromNib() {
        super.awakeFromNib()
        let image = UIImage(named: "chev_right",
                            in: PassioInternalConnector.shared.bundleForModule, compatibleWith: nil)
        sideArrowImage?.image = image
        insetBackground.roundMyCornerWith(radius: Custom.insetBackgroundRadius)
    }

}
