//
//  UIColor+Extensions.swift
//  PassioAppModule
//
//  Created by Patrick Goley on 4/20/21.
//

import UIKit

extension UIColor {

    static var defaultBlue: UIColor {
        return colorWithName("CustomBase")
    }

    static var lightBackground: UIColor {
        return colorWithName("EEEEEE")
    }

    private static func colorWithName(_ name: String) -> UIColor {
        let bundle = PassioInternalConnector.shared.bundleForModule
        #if DEBUG
        return UIColor(named: name, in: bundle, compatibleWith: nil)!
        #else
        return UIColor(named: name, in: bundle, compatibleWith: nil) ?? UIColor()
        #endif
    }
}
