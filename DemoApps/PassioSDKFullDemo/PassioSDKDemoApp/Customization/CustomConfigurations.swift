//
//  CustomConfigurations.swift
//  PassioPassport
//
//  Created by zvika on 5/13/19.
//  Copyright © 2023 Passiolife Inc. All rights reserved.
//

import UIKit
struct Custom {
    static let insetBackgroundColor = "PassioInset"// "PassioBlack40"
    static let customBase = "CustomBase"
    static let insetBackgroundRadius: CGFloat = 16.0
    static let buttonCornerRadius: CGFloat = 8.0
    static let engineeringViews = true
    static let useFirebase = true
    static let useNutritionBrowser = true
}

func uiAlertByKey(titleKey: String, messageKey: String? = nil, view: UIViewController) {

    let title = titleKey.localized
    var message: String?
    if let msg = messageKey {
        message = msg.localized
    }
    let alert = UIAlertController(title: title,
                                  message: message,
                                  preferredStyle: .alert)
    let action = UIAlertAction(title: "OK".localized, style: .cancel)
    alert.addAction(action)
    view.present(alert, animated: true)
}
