//
//  IngredientHeaderTableViewCell.swift
//  PassioPassport
//
//  Created by zvika on 2/14/19.
//  Copyright © 2023 Passiolife Inc. All rights reserved.
//

import UIKit

class IngredientHeaderTableViewCell: UITableViewCell {

    @IBOutlet weak var imageFood: UIImageView!
    @IBOutlet weak var labelName: UILabel!
    @IBOutlet weak var labelServing: UILabel!
    @IBOutlet weak var labelCalories: UILabel!
    @IBOutlet weak var labelTime: UILabel!
    @IBOutlet weak var rightChevron: UIImageView!
    @IBOutlet weak var insetBackground: UIView!
    var passioIDForCell: PassioID?

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        imageFood?.roundMyCorner()
        insetBackground?.roundMyCorner()
        rightChevron?.image = UIImage(named: "chev_right",
                                      in: PassioInternalConnector.shared.bundleForModule,
                                      compatibleWith: nil)// .rotate(radians: -.pi/2)
    }

}
