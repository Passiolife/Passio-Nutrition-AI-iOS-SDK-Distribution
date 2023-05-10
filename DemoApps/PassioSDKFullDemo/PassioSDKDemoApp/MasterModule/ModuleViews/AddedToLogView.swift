//
//  AddedToLogView.swift
//  BaseApp
//
//  Created by Zvika on 2/2/22.
//  Copyright © 2023 Passio Inc. All rights reserved.
//

import UIKit

class AddedToLogView: UIView {

    let fontName = "Avenir Heavy"
    let fontSize: CGFloat = 16
    let borderWidth: CGFloat = 3

    init(frame: CGRect, withText: String) {
        super.init(frame: frame)
        // alpha = 0
//        layer.borderWidth = borderWidth
//        layer.backgroundColor =  UIColor.clear.cgColor// .withAlphaComponent(0.8).cgColor
//        layer.borderColor = UIColor.black.cgColor

        let label = UILabel()
        label.text = withText
        label.textColor = .white
        label.font = UIFont(name: fontName, size: fontSize)
        label.backgroundColor = .black.withAlphaComponent(0.5)
        label.textAlignment = .center
        label.numberOfLines = 2
        label.frame = bounds// CGRect(x: bounds.minX, y: bounds.minY, width: bounds.maxX, height: 100)
        roundMyCorner() // (radius: Custom.buttonCornerRadius)
        addSubview(label)
    }

    func removeAfter(withDuration: Double, delay: Double) {
//        alpha = 0
//        UIView.animateKeyframes(withDuration: withDuration, delay: delay, options: [.calculationModeLinear], animations: {
//            self.alpha = 1
//
//        }, completion: { _ in

            UIView.animateKeyframes(withDuration: withDuration, delay: delay, options: .calculationModeCubic, animations: {
                self.alpha = 0
            }, completion: { _ in
                self.removeFromSuperview()
            })

//        })
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
