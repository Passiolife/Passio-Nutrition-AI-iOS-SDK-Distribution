//
//  ConfigureSettings.swift
//  PassioPassport
//
//  Created by zvika on 3/8/19.
//  Copyright © 2023 Passiolife Inc. All rights reserved.
//

import UIKit

func replaceSDKImageName(name: String, bundle: Bundle?) -> UIImage? {

  //  let nameSansSDK = name.replacingOccurrences(of: "SDK", with: "")

    if let image = UIImage(named: name) {
        return image
    } else if let image = UIImage(named: name,
                                  in: bundle,
                                  compatibleWith: nil) {
        return image
    } else {
        return nil
    }
}

func nutritionLabelFor(foodRecord: FoodRecord) -> String? {
    let allNutrition =  foodRecord.nutritionSummary
    var list = "Calories".localized + ": " + String(Int(allNutrition.calories))
    list += "\n" +  "Carbs".localized + " : " + String(Int(allNutrition.carbs))
    list += "  " + "Protein".localized + ": " + String(Int(allNutrition.protein))
    list += "  " + "Fat".localized + ": " + String(Int(allNutrition.fat))
    return list
}

func printTimestamp() -> String {
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss.SSS"
        return formatter
    }()
    return dateFormatter.string(from: Date())
}
