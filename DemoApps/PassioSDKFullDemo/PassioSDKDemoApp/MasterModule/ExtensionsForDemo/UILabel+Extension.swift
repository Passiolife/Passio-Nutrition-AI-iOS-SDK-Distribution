//
//  UILabel+Extension.swift
//  SDKApp
//
//  Created by zvika on 8/20/19.
//  Copyright © 2023 Passio Inc. All rights reserved.
//

import UIKit

extension UILabel {

    func highlight(words: [String], color: UIColor = .red) {
        guard let txtLabel = self.text?.lowercased() else {
            return
        }

        let attributeTxt = NSMutableAttributedString(string: txtLabel)

        words.forEach {
            let range: NSRange = attributeTxt.mutableString.range(of: $0, options: .caseInsensitive)
            attributeTxt.addAttribute(NSAttributedString.Key.backgroundColor, value: color, range: range)
        }
        self.attributedText = attributeTxt
    }

}
