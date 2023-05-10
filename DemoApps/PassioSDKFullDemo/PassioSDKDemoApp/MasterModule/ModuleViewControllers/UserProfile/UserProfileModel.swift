//
//  UserProfile.swift
//  Passio App Module
//
//  Created by zvika on 2/26/19.
//  Copyright © 2023 Passiolife Inc. All rights reserved.
//

import UIKit
#if canImport(PassioNutritionAISDK)
import PassioNutritionAISDK
#endif

typealias DMetric = Double
typealias DImperial = Double

enum Conversion: Double {
    case lbsToKg = 2.20562
    case inchToMeter = 39.3701
    case inchToFeet = 12.00
}

public struct UserProfileModel: Codable {
    // TO Fix  - USE  Measurement<UnitMass>
    var firstName: String?
    var lastName: String?
    var birthday: Date?
    var age: Int?
    var weight: Double?  // Kg
    var height: Double? // M
    var units = UnitSelection.imperial
    // https://docs.google.com/spreadsheets/d/1yNnF92tCB_3td7TVro3F5yeYDpaZiby6iHjzMfg8p7E/edit#gid=0
    var caloriesTarget = 2100
    var carbsPercent = 55
    var proteinPercent = 20
    var fatPercent = 25

    var carbsGrams: Int {
        caloriesTarget*carbsPercent/100/4
    }
    var proteinGrams: Int {
        caloriesTarget*proteinPercent/100/4
    }
    var fatGrams: Int {
        caloriesTarget*fatPercent/100/9
    }  // var 25 fat
//    var dailyCarbsTarget = 288  //% 55

//    var totalGrams: Int {
//        Int (dailyCarbsTarget + dailyFatTarget + dailyProteinTarget)
//    }

    // Calories = (Protein_grams + Carb_grams)4 + Fat_grams9 and Protein_Percentage = Protein_grams / Total_grams

//    var dietaryPreferences: UserDietAttribute?
    var bmi: Double? {
        guard let weight = weight, let height = height, height > 0, weight > 0 else { return nil }
        // K/M^2 metric.  or  w/h^2 * 703
        //  return (0.45 * Double(w) / sqrt(Double(h)*0.025)).roundDigits(afterDecimal: 1)
        return (weight/pow(height, 2)).roundDigits(afterDecimal: 1)
    }
    var gender: GenderSelection?
    var ageDesription: String? {
        guard let age = age else { return nil }
        return String(age)
    }
    var weightTitle: String {
        return "Weight".localized + " (" + weightUnits + ")"
    }
    var weightUnits: String {
        switch units {
        case .imperial:
            return  "Lbs".localized
        case .metric:
            return "Kg".localized
        }
    }

    var weightDespription: String? {
        guard let weight = weight else { return nil}
        switch units {
        case .imperial:
            return String((weight * Conversion.lbsToKg.rawValue ).roundDigits(afterDecimal: 1))
        case .metric:
            return String(weight.roundDigits(afterDecimal: 1))
        }
    }
    var heightTitle: String {
        return "Height".localized + " (" + heightUnits + ")"
    }
    var heightUnits: String {
        switch units {
        case .metric:
            return  "Meter".localized
        case .imperial:
            return "Feet".localized
        }
    }
    var heightDescription: String? {
        guard let height = height else { return nil }
        switch units {
        case .metric:
            return String(height.roundDigits(afterDecimal: 2))
        case .imperial:
            let inches = Int(height * Conversion.inchToMeter.rawValue )
            let inch = inches%Int(Conversion.inchToFeet.rawValue)
            let feet = Int(inches/Int(Conversion.inchToFeet.rawValue))
            return ("\(feet)\' \(inch)\"")
        }
    }

    var bmiDescription: String {
        guard let bmi = bmi else { return "BMIPlaceHolder".localized }
        let cdc: String
        switch bmi {
        case 0...18.5:
            cdc = "Underweight"
        case 18.5...24.9:
            cdc = "Healthy Weight"
        case 24.9...29.9:
            cdc = "Overweight"
        default:
            cdc = "Obese"
        }
        return "Body mass index \(bmi)\nCDC ranking:\n\(cdc)"
    }

    // MARK: Picker helprs
    var heightArrayForPicker: [[String]] {
        switch units {
        case .metric:
            let arrayOne = Array(0...2).map { String($0) + " m" }
            let arrayTwo = Array(0...99).map { String($0) + " cm" }
            return [arrayOne, arrayTwo]
        case .imperial:
            let arrayOne = Array(0...8).map { String($0) + "'" }
            let arrayTwo = Array(0...11).map { String($0) + "\"" }
            return [arrayOne, arrayTwo]
        }
    }

    var heightInitialValueForPicker: [Int] {
        switch units {
        case .metric:
            if let height = height {
                return [Int(height), Int((height-Double(Int(height)))*100)]
            } else {
                return [1, 65]
            }
        case .imperial:
            if let height = height {
                let heightInInches = Int(height*Conversion.inchToMeter.rawValue)
                return [heightInInches/Int(Conversion.inchToFeet.rawValue),
                        heightInInches%Int(Conversion.inchToFeet.rawValue)]
            } else {
                return [5, 6]
            }
        }
    }

    mutating func setHeightInMetersFor(compOne: Int, compTwo: Int) {
        switch units {
        case .metric:
            height = Double(compOne) + Double(compTwo)/100.0
        case .imperial:
            height = Double(compOne*Int(Conversion.inchToFeet.rawValue) + compTwo)/Conversion.inchToMeter.rawValue
        }
    }

    var getJSONDict: [String: Any]? {
        if let data = try? JSONEncoder().encode(self),
            let dic = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
            return dic
        }
        return nil
    }

}

enum GenderSelection: String, Codable, CaseIterable {
    case female
    case male
    case other
}

enum UnitSelection: String, Codable, CaseIterable {
    case imperial
    case metric
}
