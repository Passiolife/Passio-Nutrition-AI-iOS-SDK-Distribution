//
//  UIFont+Extensions.swift
//  PassioAppModule
//
//  Created by Patrick Goley on 4/26/21.
//

import UIKit

extension UIFont {
    static func avenirMedium(size: CGFloat) -> UIFont {
        UIFont(name: "Avenir-Medium", size: size) ?? .systemFont(ofSize: size)
    }
}
