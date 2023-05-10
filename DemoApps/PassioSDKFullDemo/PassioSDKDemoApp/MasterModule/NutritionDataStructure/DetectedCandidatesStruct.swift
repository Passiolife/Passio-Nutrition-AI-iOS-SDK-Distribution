//
//  DetectedCandidatesStruct.swift
//  BaseApp
//
//  Created by Zvika on 2/4/22.
//  Copyright © 2023 Passio Inc. All rights reserved.
//

import UIKit
#if canImport(PassioNutritionAISDK)
import PassioNutritionAISDK
#endif

struct DetectedCandidatesStruct: DetectedCandidate {
    var passioID: PassioID
    var confidence: Double
    var boundingBox: CGRect
    var croppedImage: UIImage?
    var amountEstimate: AmountEstimate?
}
