//
//  Macros.swift
//  BaseApp
//
//  Created by zvika on 1/11/21.
//  Copyright © 2023 Passio Inc. All rights reserved.
//

import Foundation

// Calories = (Protein_grams + Carb_grams)4 + Fat_grams9 and Protein_Percentage = Protein_grams / Total_grams
// Calories = ( TotalGrams* proteinPercent + TotalGrams * carbsPercent ) *4 + TotalGrams * fatPercent * 9
// Calorie = TotalGrams ((proteinPercent + carbsPercent) *4 + fatPrecent *9)
// totalGrams = Calories / ((proteinPercent + carbsPercent) *4 + fatPrecent *9)
struct Macros {
    var caloriesTarget = 2100 {
        didSet {
            if caloriesTarget < 0 {
                caloriesTarget = 0
            }
        }
    }

    private(set) var carbsPercent = 55
    private(set) var proteinPercent = 20
    private(set) var fatPercent = 25

    var carbsGrams: Int {
        caloriesTarget * carbsPercent / 100 / 4
    }

    var proteinGrams: Int {
        caloriesTarget * proteinPercent / 100 / 4
    }

    var fatGrams: Int {
        caloriesTarget * fatPercent / 100 / 9
    }

    init(caloriesTarget: Int,
         carbsPercent: Int,
         proteinPercent: Int,
         fatPercent: Int) {
        guard caloriesTarget >= 0 &&
                carbsPercent >= 0 &&
                proteinPercent >= 0 &&
                fatPercent >= 0 &&
                (carbsPercent + proteinPercent + fatPercent == 100) else {
            return
        }
        self.caloriesTarget = caloriesTarget
        self.carbsPercent = carbsPercent
        self.proteinPercent = proteinPercent
        self.fatPercent = fatPercent
    }

    mutating func set(carbs: Int) {
        (carbsPercent, proteinPercent, fatPercent) = balance3Values(first: carbs, second: proteinPercent, third: fatPercent )
    }

    mutating func set(protein: Int) {
        (proteinPercent, fatPercent, carbsPercent) = balance3Values(first: protein, second: fatPercent, third: carbsPercent)
    }

    mutating func set(fat: Int) {
        (fatPercent, proteinPercent, carbsPercent) = balance3Values(first: fat, second: proteinPercent, third: carbsPercent)
    }

    private func balance3Values(first: Int, second: Int, third: Int) -> (first: Int, second: Int, third: Int) {
        let validateFirst = validatePercent(valuein: first)
        if (validateFirst + third) > 100 {
            return(validateFirst, 0, 100 - validateFirst)
        } else {
            return( validateFirst, 100 - validateFirst - third, third)
        }
    }

    private func validatePercent(valuein: Int) -> Int {
        if valuein > 100 {
            return 100
        } else if valuein < 0 {
            return 0
        } else {
            return valuein
        }
    }

}
