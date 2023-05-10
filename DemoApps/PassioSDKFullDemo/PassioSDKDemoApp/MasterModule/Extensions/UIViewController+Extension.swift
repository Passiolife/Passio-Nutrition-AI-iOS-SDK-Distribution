//
//  UIViewControllerExtension.swift
//  Passio App Module
//
//  Created by zvika on 1/28/19.
//  Copyright © 2023 Passiolife Inc. All rights reserved.
//

import UIKit
extension UIViewController {

    func customizeNavForModule(withBackButton: Bool = true) {
        guard let navBar = self.navigationController?.navigationBar else { return }
        navBar.setBackgroundImage(nil, for: .default)
        let textAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black]
        navBar.titleTextAttributes = textAttributes
        navBar.tintColor = .black
        if withBackButton {
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "Back".localized,
                                                           style: .plain,
                                                           target: nil,
                                                           action: nil)
        } else {
            navigationItem.hidesBackButton = true
        }
    }

    func hideKeyboardWhenTappedAround() {
        let tapGesture = UITapGestureRecognizer(target: self,
                                                action: #selector(hideKeyboard))
        view.addGestureRecognizer(tapGesture)
    }

    @objc func hideKeyboard() {
        view.endEditing(true)
    }

}
