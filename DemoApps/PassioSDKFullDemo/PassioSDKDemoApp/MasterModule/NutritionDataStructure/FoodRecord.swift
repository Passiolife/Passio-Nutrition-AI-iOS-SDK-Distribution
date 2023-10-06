//
//  FoodRecord.swift
//  PassioPassport
//
//  Created by Former Developer on 4/24/18.
//  Copyright © 2023 Passiolife Inc. All rights reserved.
//

import Foundation
#if canImport(PassioNutritionAISDK)
import PassioNutritionAISDK
#endif

public typealias NutritionSummary = (calories: Double, carbs: Double, protein: Double, fat: Double)

public struct FoodRecord: Codable, Equatable {

    public var name: String
    public var uuid: String
    public var createdAt: Date
    public var mealLabel: MealLabel
    public let passioID: PassioID
    public var visualPassioID: PassioID?
    public var visualName: String?
    public var nutritionalPassioID: PassioID?
    public var servingSizes: [PassioServingSize]
    public var servingUnits: [PassioServingUnit]
    public var scannedUnitName = "scanned amount"
    public var condiments: [PassioFoodItemData]?
    public var entityType: PassioIDEntityType
    public var isOpenFood: Bool {
        for ingredient in ingredients {
            if ingredient.isOpenFood { return true }
        }
        return false
    }
    private(set) public var selectedUnit: String
    private(set) public var selectedQuantity: Double
    private(set) public var ingredients: [PassioFoodItemData]

    private(set) public var parents: [PassioAlternative]?
    private(set) public var siblings: [PassioAlternative]?
    private(set) public var children: [PassioAlternative]?
    public var alternatives: [PassioAlternative]? {
        let alt = (parents ?? []) + (children ?? []) + (siblings ?? [])
        return alt.isEmpty ? nil : alt
    }

     // computed properties
    public var alternativesPassioID: [PassioID]? { alternatives?.compactMap { $0.passioID } }
    public var totalCalories: Double {
        ingredients.map {$0.totalCalories?.value ?? 0}.reduce(0.0, +).roundDigits(afterDecimal: 0)
    }
    public var totalCarbs: Double {
        ingredients.map {$0.totalCarbs?.value ?? 0}.reduce(0.0, +).roundDigits(afterDecimal: 1)
    }
    public var totalProteins: Double {
        ingredients.map {$0.totalProteins?.value ?? 0}.reduce(0.0, +).roundDigits(afterDecimal: 1)
    }
    public var totalFat: Double {
        ingredients.map {$0.totalFat?.value ?? 0}.reduce(0.0, +).roundDigits(afterDecimal: 1)
    }
    public var nutritionSummary: NutritionSummary {
         (calories: totalCalories, carbs: totalCarbs, protein: totalProteins, fat: totalFat)
    }

    public var nutritionLabel: String? {
        let allNutrition =  nutritionSummary
        var list = "Calories".localized + ": " + String(Int(allNutrition.calories))
        list += "\n" +  "Carbs".localized + " : " + String(Int(allNutrition.carbs))
        list += "  " + "Protein".localized + ": " + String(Int(allNutrition.protein))
        list += "  " + "Fat".localized + ": " + String(Int(allNutrition.fat))
        return list
    }

    public var computedWeight: Measurement<UnitMass> {
        guard let weight2UnitRatio = (servingUnits.filter {$0.unitName == selectedUnit}).first?.weight.value else {
            return Measurement<UnitMass>(value: 0, unit: .grams)
        }
        return Measurement<UnitMass>(value: weight2UnitRatio * selectedQuantity, unit: .grams)
    }

    mutating public func addScannedAmount(scannedWeight: Double) {
        guard scannedWeight > 1, scannedWeight < 50000 else { return }
        let scannedServingUnit = PassioServingUnit(unitName: scannedUnitName, weight: Measurement<UnitMass>(value: scannedWeight, unit: .grams))
        let scannedServingSize = PassioServingSize(quantity: 1, unitName: scannedUnitName)
        servingUnits.insert(scannedServingUnit, at: 0) // append(scannedServingUnit
        servingSizes.insert(scannedServingSize, at: 0)
        _ = setFoodRecordServing(unit: scannedUnitName, quantity: 1)
    }

    public var getJSONDict: [String: Any] {
        if let data = getJSONData,
            let dic = try? JSONSerialization.jsonObject(with: data, options: []),
            let finlaDic = dic as? [String: Any] {
            return finlaDic
        } else {
            return [:]
        }
    }

    var getJSONData: Data? {
        let encoder = JSONEncoder()
        if let jsonData = try? encoder.encode(self) {
            return jsonData
        } else {
            return nil
        }
    }

    mutating public func setFoodRecordServing(unit: String, quantity: Double) -> Bool {
        guard  (servingUnits.filter {$0.unitName == unit}).first?.weight != nil else {
            return false
        }
        selectedUnit = unit
        selectedQuantity = quantity != 0 ? quantity : 0.001
        computeQuantityForIngredients()
        return true
    }

    mutating public func setSelectedUnitKeepWeight(unitName: String ) -> Bool {
        guard let weight2Quantity = (servingUnits.filter {$0.unitName == unitName}).first?.weight else {
            return false
        }
        selectedQuantity = computedWeight.value / weight2Quantity.value
        selectedUnit = unitName
        computeQuantityForIngredients()
        return true
    }

    mutating public func addIngredient(ingredient: PassioFoodItemData, isFirst: Bool = false) {
        if ingredients.count == 1 { // this is when a food Item become a recipe
            name = "Recipe with".localized + " " + ingredients[0].name
        }
        if isFirst {
            ingredients.insert(ingredient, at: 0)
        } else {
            ingredients.append(ingredient)
        }
        computeQuantityForRecipe()
        _ = setSelectedUnitKeepWeight(unitName: "gram")
        servingSizes = [PassioServingSize(quantity: selectedQuantity, unitName: selectedUnit)]
        if ingredients.count > 1 {
            entityType = .recipe
        }
    }

    mutating public func replaceIngredient(updatedIngredient: PassioFoodItemData, atIndex: Int) -> Bool {
        guard atIndex < ingredients.count else { return false }
        ingredients[atIndex] = updatedIngredient
        computeQuantityForRecipe()
        return true
    }

    mutating public func replaceAllIngredientsWith(newIngredients: [PassioFoodItemData],
                                                   keepRecipeAmounts: Bool) {
        ingredients = newIngredients
        if keepRecipeAmounts {
            computeQuantityForIngredients()
        } else {
            computeQuantityForRecipe()
        }
    }

    mutating public func removeIngredient(atIndex: Int) -> Bool {
        guard atIndex < ingredients.count else { return false}
        ingredients.remove(at: atIndex)
        if ingredients.count == 1, let ingredient = ingredients.first {
            name = ingredient.name
            selectedUnit = ingredient.selectedUnit
            selectedQuantity = ingredient.selectedQuantity
            servingSizes = ingredient.servingSizes
            servingUnits = ingredient.servingUnits
            entityType = ingredient.entityType
        }
        computeQuantityForRecipe()
        return true
    }

    mutating private func computeQuantityForRecipe() {
        let totalWeight = ingredients.map {$0.computedWeight.value}.reduce(0, +)
        if let servingSizeUnit = servingUnits.filter({ $0.unitName == selectedUnit }).first {
            selectedQuantity = totalWeight/servingSizeUnit.weight.value
        }
    }

    mutating private func computeQuantityForIngredients() {
        let totalWeight = ingredients.map {$0.computedWeight.value}.reduce(0, +)
        let ratioMultiply = computedWeight.value/totalWeight
        var newIngredient = [PassioFoodItemData]()
        ingredients.forEach {
            var tempFood = $0
            _ = tempFood.setFoodItemDataServingSize(unit: tempFood.selectedUnit,
                                                    quantity: tempFood.selectedQuantity * ratioMultiply)
            newIngredient.append(tempFood)
        }
        ingredients = newIngredient
    }

    init(passioIDAttributes: PassioIDAttributes,
         replaceVisualPassioID: PassioID?,
         replaceVisualName: String?,
         scannedWeight: Double? = nil) {
        passioID = passioIDAttributes.passioID
        if let vPassioID = replaceVisualPassioID {
            visualPassioID = vPassioID
        } else {
            visualPassioID = passioIDAttributes.passioID
        }
        if let vName = replaceVisualName {
            visualName = vName
        } else {
            visualName = passioIDAttributes.name
        }
        name = passioIDAttributes.name

        if passioIDAttributes.entityType == .recipe,
            let recipe = passioIDAttributes.recipe { // Recipe
            ingredients = recipe.foodItems
            selectedUnit = recipe.selectedUnit
            selectedQuantity = recipe.selectedQuantity
            servingSizes = recipe.servingSizes
            servingUnits = recipe.servingUnits
            nutritionalPassioID = recipe.passioID
        } else { // Not a Recipe
            if let foodItemData = passioIDAttributes.passioFoodItemData {
                nutritionalPassioID = foodItemData.passioID
                ingredients = [foodItemData]
                selectedUnit = foodItemData.selectedUnit
                selectedQuantity = foodItemData.selectedQuantity
                servingSizes = foodItemData.servingSizes
                servingUnits = foodItemData.servingUnits
            } else {
                nutritionalPassioID = passioID
                ingredients = []
                selectedUnit = "gram"
                selectedQuantity = 0.0
                servingSizes = []
                servingUnits = []
            }
        }
        parents = passioIDAttributes.parents
        siblings = passioIDAttributes.siblings
        children = passioIDAttributes.children
        entityType = passioIDAttributes.entityType
        let now = Date()
        createdAt = now
        mealLabel = MealLabel.mealLabelBy(time: now)
        uuid = UUID().uuidString

        if let scannedWeight = scannedWeight {
            addScannedAmount(scannedWeight: scannedWeight)
        } else {
            _ = setFoodRecordServing(unit: selectedUnit, quantity: selectedQuantity)
        }
    }

}
