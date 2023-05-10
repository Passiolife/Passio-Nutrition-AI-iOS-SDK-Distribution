//
//  EditIngredientViewController.swift
//  Passio App Module
//
//  Created by zvika on 3/28/19.
//  Copyright © 2023 Passiolife Inc. All rights reserved.
//

import UIKit
#if canImport(PassioNutritionAISDK)
import PassioNutritionAISDK
#endif

class EditIngredientViewController: UIViewController {
    var ingredientEditorView: IngredientEditorView?
    var foodItemData: PassioFoodItemData?
    var indexOfIngredient = 0
    var isFavoriteTemplate = false
    let bundleForModule = PassioInternalConnector.shared.bundleForModule
    weak var delegate: IngredientEditorViewDelegate?
    var saveOnDismiss = true

    override func viewDidLoad() {
        super.viewDidLoad()
        customizeNavForModule()
        let nib = UINib(nibName: "IngredientEditorView", bundle: bundleForModule)
        ingredientEditorView = nib.instantiate(withOwner: self, options: nil).first as? IngredientEditorView
        ingredientEditorView?.foodItemData = foodItemData
        ingredientEditorView?.indexOfIngredient = indexOfIngredient
        ingredientEditorView?.delegate = self
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let image = UIImage(named: "App_Background", in: bundleForModule, compatibleWith: nil)
        let imageView = UIImageView(image: image)
        imageView.frame = view.bounds
        imageView.contentMode = .scaleToFill
        view.addSubview(imageView)
        view.backgroundColor = UIColor(named: "CustomBack", in: bundleForModule, compatibleWith: nil)
        ingredientEditorView?.frame = view.bounds
        if let ingredientEditorView = ingredientEditorView {
            view.addSubview(ingredientEditorView)
        }
        title = foodItemData?.name.capitalized
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if saveOnDismiss, let foodItem = ingredientEditorView?.foodItemData {
            delegate?.ingredientEditedFoodItemData(foodItemData: foodItem, atIndex: indexOfIngredient)
        }
    }

}

extension EditIngredientViewController: IngredientEditorViewDelegate {

    func startNutritionBrowser(foodItemData: PassioFoodItemData) {

        guard let pAtt = PassioNutritionAI.shared.lookupPassioIDAttributesFor(passioID: foodItemData.passioID) else {
            return
        }

        let nbVC = BrowseNutritionViewController()

        nbVC.foodRecord = FoodRecord(passioIDAttributes: pAtt,
                                     replaceVisualPassioID: nil,
                                     replaceVisualName: nil)
        nbVC.delegate = self
        self.navigationController?.pushViewController(nbVC, animated: true)

    }

    func ingredientEditedFoodItemData(foodItemData: PassioFoodItemData, atIndex: Int) {
        navigationController?.popViewController(animated: true)
    }

    func ingredientEditedCancel() {
        saveOnDismiss = false
        navigationController?.popViewController(animated: true)
    }

}

extension EditIngredientViewController: NutritionBrowserDelegate {

    func userSelectedFromNBrower(foodRecord: FoodRecord?) {
               ingredientEditorView?.foodItemData = foodRecord?.ingredients.first
    }

    func userCancelledNBrowser(originalRecord: FoodRecord?) {
        // Do nothing.
    }
}
