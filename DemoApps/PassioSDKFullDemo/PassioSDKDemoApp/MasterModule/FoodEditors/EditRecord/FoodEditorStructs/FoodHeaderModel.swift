//
//  FoodHeaderModel.swift
//  BaseApp
//
//  Created by zvika on 5/3/20.
//  Copyright © 2023 Passio Inc. All rights reserved.
//

import Foundation

struct FoodHeaderModel {
    var labelName = ""
    var labelServing = ""
    var calories = "0"
    var carbs = "0"
    var protein = "0"
    var fat = "0"
    let labelCal = "Calories".localized
    let labelCarbs = "Carbs".localized
    let labelProtein = "Protein".localized
    let lableFat = "Fat".localized

    init(foodRecord: FoodRecord) {
        labelName = foodRecord.name.capitalized
        let quantity = foodRecord.selectedQuantity
        let unitName = foodRecord.selectedUnit.capitalized
        let weight = String(Int(foodRecord.computedWeight.value))
        let textAmount = quantity == Double(Int(quantity)) ? String(Int(quantity)) :
            String(quantity.roundDigits(afterDecimal: 2))

        let displayUnit = "g".localized

        print("unitName = \(unitName)")
        let weightText = unitName == "g" ? "" : "(" + weight + " " + displayUnit + ") "
        labelServing = textAmount + " " + unitName + " " + weightText
        calories = String(foodRecord.totalCalories.roundDigits(afterDecimal: 1))
        carbs = String(foodRecord.totalCarbs.roundDigits(afterDecimal: 1))
        protein = String(foodRecord.totalProteins.roundDigits(afterDecimal: 1))
        fat = String(foodRecord.totalFat.roundDigits(afterDecimal: 1))
    }
}
