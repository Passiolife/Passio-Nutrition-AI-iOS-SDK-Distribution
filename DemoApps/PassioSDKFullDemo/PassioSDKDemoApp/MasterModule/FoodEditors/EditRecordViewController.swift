//
//  EditRecordViewController.swift
//  Passio App Module
//
//  Created by zvika on 3/28/19.
//  Copyright © 2023 Passiolife Inc. All rights reserved.
//

import UIKit
#if canImport(PassioNutritionAISDK)
import PassioNutritionAISDK
#endif

class EditRecordViewController: UIViewController {

    var foodEditorView: FoodEditorView?
    var foodRecord: FoodRecord?
    let connector = PassioInternalConnector.shared
    weak var delegate: FoodEditorDelegate?
    var saveOnDisappear = true
    var isEditingFavorite = false

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(named: "CustomBack", in: connector.bundleForModule, compatibleWith: nil)
        let nib = UINib(nibName: "FoodEditorView", bundle: connector.bundleForModule)
        foodEditorView = nib.instantiate(withOwner: self, options: nil).first as? FoodEditorView
        customizeNavForModule()
        foodEditorView?.foodRecord = foodRecord
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        title = foodEditorView?.foodRecord?.name.capitalized
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        foodEditorView?.frame = view.bounds
        foodEditorView?.delegate = self
        foodEditorView?.isEditingFavorite = isEditingFavorite
        if let foodEditorView = foodEditorView {
            view.addSubview(foodEditorView)
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if saveOnDisappear, let foodRecord = foodEditorView?.foodRecord {
            if isEditingFavorite {// foodRecord.isFavorite {
                connector.updateFavorite(foodRecord: foodRecord)
            } else {
                connector.updateRecord(foodRecord: foodRecord, isNew: false)
            }
        }
        saveOnDisappear = true // for disappearing while navigating deeper
    }

}

extension EditRecordViewController: FoodEditorDelegate {

    func startNutritionBrowser(foodRecord: FoodRecord) {
        let nbVC = BrowseNutritionViewController()
        nbVC.foodRecord = foodRecord
        nbVC.delegate = self
        self.navigationController?.pushViewController(nbVC, animated: true)
        saveOnDisappear = false
    }

    func animateMicroTotheLeft() {

    }

    func addFoodToLog(foodRecord: FoodRecord) {
        displayAdded()
        if isEditingFavorite {
            connector.updateFavorite(foodRecord: foodRecord)
        }
        saveOnDisappear = false
        navigationController?.popViewController(animated: true)
    }

    func displayAdded() {
        let width: CGFloat = 200
        let height: CGFloat = 40
        let fromButton: CGFloat = 100
        let frame = CGRect(x: (view.bounds.width - width)/2,
                           y: view.bounds.height - fromButton,
                           width: width,
                           height: height)
        let addedToLog = AddedToLogView(frame: frame, withText: "Item added to log")
        view.addSubview(addedToLog)
        addedToLog.removeAfter(withDuration: 1, delay: 1)
    }

    func addFoodFavorites(foodRecord: FoodRecord) {
        delegate?.addFoodFavorites(foodRecord: foodRecord)
    }

    func foodEditorCancel() {
        saveOnDisappear = false
        navigationController?.popViewController(animated: true)
    }

    func userSelected(ingredient: PassioFoodItemData, indexOfIngredient: Int) {
        let editVC = EditIngredientViewController()
        editVC.foodItemData = ingredient
        editVC.indexOfIngredient = indexOfIngredient
        editVC.delegate = self
        self.navigationController?.pushViewController(editVC, animated: true)
        saveOnDisappear = false
    }

    func foodEditorSearchText() {
        let tsVC = TextSearchViewController(nibName: "TextSearchViewController", bundle: connector.bundleForModule)
        tsVC.delegate = self
        navigationController?.pushViewController(tsVC, animated: true)
        saveOnDisappear = false
    }

    func rescanVolume() {
    }

}

extension EditRecordViewController: IngredientEditorViewDelegate {

    func startNutritionBrowser(foodItemData: PassioFoodItemData) {
    }

    func ingredientEditedFoodItemData(foodItemData: PassioFoodItemData, atIndex: Int) {
        _ = foodEditorView?.foodRecord?.replaceIngredient(updatedIngredient: foodItemData, atIndex: atIndex)
    }

    func ingredientEditedCancel() {
    }

}

extension EditRecordViewController: TextSearchViewDelgate {

    func userSelectedFoodItemViaText(passioIDAndName: PassioIDAndName?) {
        guard let passioIDAndName = passioIDAndName else {
            navigationController?.popViewController(animated: true)
            return
        }
        if let pidAtt = PassioNutritionAI.shared.lookupPassioIDAttributesFor(passioID: passioIDAndName.passioID) {
            if let newFoodItem = pidAtt.passioFoodItemData {
                foodEditorView?.foodRecord?.addIngredient(ingredient: newFoodItem, isFirst: true)
            } else if pidAtt.entityType == .recipe, let recipe = pidAtt.recipe {
                recipe.foodItems.reversed().forEach {
                    foodEditorView?.foodRecord?.addIngredient(ingredient: $0, isFirst: true)
                }
            }
        }
        navigationController?.popViewController(animated: true)
    }

}

extension EditRecordViewController: NutritionBrowserDelegate {

    func userSelectedFromNBrower(foodRecord: FoodRecord?) {
        if let foodEditorView = foodEditorView {
            foodEditorView.foodRecord = foodRecord
        }
    }

    func userCancelledNBrowser(originalRecord: FoodRecord?) {
        // Do nothing.
    }
}
