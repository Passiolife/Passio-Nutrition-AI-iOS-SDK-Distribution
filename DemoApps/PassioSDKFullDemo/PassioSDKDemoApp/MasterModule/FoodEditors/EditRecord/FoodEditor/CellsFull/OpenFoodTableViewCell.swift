//
//  OpenFoodTableViewCell.swift
//  PassioPassport
//
//  Created by zvika on 2/14/19.
//  Copyright © 2023 Passiolife Inc. All rights reserved.
//

import UIKit

class OpenFoodTableViewCell: UITableViewCell {

    @IBOutlet weak var insetBackground: UIView!
    @IBOutlet weak var textView: UITextView!

    override func awakeFromNib() {
        super.awakeFromNib()
        let attributedString = NSMutableAttributedString(string: "This record contains information from Open Food Facts, which is made available here under the Open Database License")
        attributedString.addAttribute(.link, value: "https://en.openfoodfacts.org",
                                      range: (attributedString.string as NSString).range(of: "Open Food Facts"))
        attributedString.addAttribute(.link, value: "https://opendatacommons.org/licenses/odbl/1-0",
                                      range: (attributedString.string as NSString).range(of: "Open Database License"))
        textView.attributedText = attributedString
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        insetBackground?.roundMyCornerWith(radius: Custom.insetBackgroundRadius)
    }

    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        UIApplication.shared.open(URL)
        return false
    }
}
