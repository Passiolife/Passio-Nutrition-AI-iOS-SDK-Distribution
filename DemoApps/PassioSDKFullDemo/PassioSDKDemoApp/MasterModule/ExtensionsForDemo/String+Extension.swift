//
//  String+Extension.swift
//
//  Created by Former Developer on 02/06/18.
//  Copyright © 2023 Passiolife All rights reserved.
//

import Foundation

extension String {

    var isValidEmail: Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailTest = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: self)
    }

    var localized: String {
        let bundlePod = PassioInternalConnector.shared.bundleForModule
        return NSLocalizedString(self, tableName: "Localizable",
                                 bundle: bundlePod,
                                 value: self, comment: "")
    }

    func capitalizingFirst() -> String {
        return prefix(1).capitalized + dropFirst()
    }

    mutating func capitalizeFirst() {
        self = self.capitalizingFirst()
    }

    func plural() -> String {
        if hasSuffix("s") {
            return self
        }
        if hasSuffix("y") {
            var copy = self
            copy.removeLast(1)
            return copy + "ies"
        }
        return self + "s"
    }
}
