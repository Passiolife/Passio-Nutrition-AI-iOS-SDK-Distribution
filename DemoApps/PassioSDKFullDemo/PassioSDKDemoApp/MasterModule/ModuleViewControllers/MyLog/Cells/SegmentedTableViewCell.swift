//
//  SegmentedTableViewCell.swift
//  Passio App Module
//
//  Created by zvika on 2/13/19.
//  Copyright © 2023 Passiolife Inc. All rights reserved.
//

import UIKit

class SegmentedTableViewCell: UITableViewCell {

    @IBOutlet weak var segmented: UISegmentedControl!
    @IBOutlet weak var insetBackground: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        insetBackground.roundMyCornerWith(radius: 10)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
