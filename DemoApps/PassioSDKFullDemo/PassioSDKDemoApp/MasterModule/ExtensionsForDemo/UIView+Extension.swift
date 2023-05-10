//
//  UIView.swift
//  PassioPassport
//
//  Created by Former Developer on 6/3/18.
//  Copyright © 2023 Passiolife Inc. All rights reserved.
//

import Foundation
import UIKit

extension UIView {

    func roundMyCorner() {
        let radius = min(self.bounds.height, self.bounds.width)/2
        self.layer.cornerRadius = radius
        self.layer.masksToBounds = true
        self.clipsToBounds = true
    }

    func roundMyCornerWith(radius: CGFloat) {
        self.layer.cornerRadius = radius
        self.layer.masksToBounds = true
        self.clipsToBounds = true
    }

    func roundMyCornerWith(radius: CGFloat, upper: Bool, down: Bool ) {
      //  self.frame = self.frame.insetBy(dx: withInset, dy: withInset)
        self.layer.cornerRadius = radius
        self.layer.masksToBounds = true
        if upper {
        self.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        }
        if down {
            self.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        }
        self.clipsToBounds = true
    }

//    func dropShadow(scale: Bool = true) {
//        
//         layer.shadowColor = UIColor.black.cgColor
//         layer.shadowOpacity = 0.2
//         layer.shadowOffset = .zero
//         layer.shadowRadius = 10
// //layer.masksToBounds = false
//         layer.shouldRasterize = true
//         layer.rasterizationScale = scale ? UIScreen.main.scale : 1
//     }

    func fadeIn(seconds: Double) {
        self.alpha = 0

        UIView.animateKeyframes(withDuration: seconds, delay: 0, options: .calculationModeLinear, animations: {
                self.alpha = 1
            })

    }

    func findViewController() -> UIViewController? {
           if let nexrResponder = self.next as? UIViewController {
               return nexrResponder
           } else if let nextResponder = self.next as? UIView {
               return nextResponder.findViewController()
           } else {
               return nil
           }
       }

    private static let kRotationAnimationKey = "rotationanimationkey"

    func startRotating(duration: Double = 1) {
        guard layer.animation(forKey: UIView.kRotationAnimationKey) == nil else { return }
        let rotation: CABasicAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotation.fromValue = 0.0
        rotation.toValue = Float.pi * 2.0
        rotation.duration = duration
        rotation.isCumulative = true
        rotation.repeatCount = Float.infinity
        self.layer.add(rotation, forKey: UIView.kRotationAnimationKey)
    }

    func stopRotating() {
        if layer.animation(forKey: UIView.kRotationAnimationKey) != nil {
            layer.removeAnimation(forKey: UIView.kRotationAnimationKey)
        }
    }

    func fadeOut(seconds: Double) {
        self.alpha = 1
        UIView.animateKeyframes(withDuration: seconds, delay: 0, options: .calculationModeLinear, animations: {
            self.alpha = 0
        })
    }

    func roundCornerRadius(radius: CGFloat) {
        self.layer.cornerRadius = radius
        self.layer.masksToBounds = true
        self.clipsToBounds = true
    }

    func startRotatingView(duration: Double = 1) {
        guard layer.animation(forKey: UIView.kRotationAnimationKey) == nil else { return }
        let rotation: CABasicAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotation.fromValue = 0.0
        rotation.toValue = Float.pi * 2.0
        rotation.duration = duration
        rotation.isCumulative = true
        rotation.repeatCount = Float.infinity
        self.layer.add(rotation, forKey: UIView.kRotationAnimationKey)
    }

    func stopRotatingView() {
        if layer.animation(forKey: UIView.kRotationAnimationKey) != nil {
            layer.removeAnimation(forKey: UIView.kRotationAnimationKey)
        }
    }
}
