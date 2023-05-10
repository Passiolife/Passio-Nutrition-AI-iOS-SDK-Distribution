//
//  Double+Extension.swift
//  Passio App Module
//
//  Created by zvika on 1/29/19.
//  Copyright © 2023 Passiolife Inc. All rights reserved.
//

import Foundation
import PassioNutritionAISDK

extension Optional where Wrapped == Double {

    func roundDigits(afterDecimal: Int) -> Double? {
        guard let wself = self else {return nil}
        let multiplier = pow(10, Double(afterDecimal))
        return (wself * multiplier).rounded()/multiplier
    }

}

extension Double {

    func roundDigits(afterDecimal: Int) -> Double {
        let multiplier = pow(10, Double(afterDecimal))
        return (self * multiplier).rounded()/multiplier
    }

}
