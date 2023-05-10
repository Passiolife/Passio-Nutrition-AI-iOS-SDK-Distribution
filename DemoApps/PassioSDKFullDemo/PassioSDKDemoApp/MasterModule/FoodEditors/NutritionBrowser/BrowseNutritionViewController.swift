//
//  BrowseNutritionViewController.swift
//  BaseApp
//
//  Created by zvika on 3/12/21.
//  Copyright © 2023 Passio Inc. All rights reserved.
//

import UIKit

class BrowseNutritionViewController: UIViewController {

    let bundleForModule = PassioInternalConnector.shared.bundleForModule

    var nutritionBrowserView: NutritionBrowserView?
    var foodRecord: FoodRecord?
    weak var delegate: NutritionBrowserDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .orange
        view.backgroundColor = UIColor(named: "CustomBack", in: bundleForModule, compatibleWith: nil)
        let nib = UINib(nibName: "NutritionBrowserView", bundle: bundleForModule)
        nutritionBrowserView = nib.instantiate(withOwner: self, options: nil).first as? NutritionBrowserView
        nutritionBrowserView?.foodRecord = foodRecord
        nutritionBrowserView?.delegate = self
        customizeNavForModule()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        nutritionBrowserView?.frame = view.bounds
        if let nutritionBrowserView = nutritionBrowserView {
            view.addSubview(nutritionBrowserView)
        }
    }
}

extension BrowseNutritionViewController: NutritionBrowserDelegate {

    func userSelectedFromNBrower(foodRecord: FoodRecord?) {
        delegate?.userSelectedFromNBrower(foodRecord: foodRecord)
        navigationController?.popViewController(animated: true)
    }

    func userCancelledNBrowser(originalRecord: FoodRecord?) {
        delegate?.userCancelledNBrowser(originalRecord: originalRecord)
        navigationController?.popViewController(animated: true)
    }

}
