//
//  UITableView+Extention.swift
//  BaseApp
//
//  Created by zvika on 5/6/20.
//  Copyright © 2023 Passio Inc. All rights reserved.
//

import UIKit

extension UITableView {

    func reloadWithAnimations(withDuration: Double = 0.5) {
        UIView.transition(with: self, duration: withDuration,
                          options: [.transitionCrossDissolve, .allowUserInteraction],
                          animations: {
            self.reloadData()
        })
    }

}
