//
//  UIApplication+Extension.swift
//  BaseApp
//
//  Created by Zvika on 2/2/22.
//  Copyright © 2023 Passio Inc. All rights reserved.
//

import UIKit

extension UIWindow {
    static func getTopViewController() -> UIViewController? {
        if #available(iOS 13, *) {
            let keyWindow = UIApplication.shared.windows.filter {$0.isKeyWindow}.first

            if var topController = keyWindow?.rootViewController {
                while let presentedViewController = topController.presentedViewController {
                    topController = presentedViewController
                }
                return topController
            }
        } else {
            if var topController = UIApplication.shared.keyWindow?.rootViewController {
                while let presentedViewController = topController.presentedViewController {
                    topController = presentedViewController
                }
                return topController
            }
        }
        return nil
    }
}
