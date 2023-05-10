//
//  SDKApp
//
//  Created by zvika on 7/22/19.
//  Copyright © 2019 Passio Inc. All rights reserved.
//

import UIKit
import PassioSDKiOS

class LogoLabel: UILabel {

    let fontName = "Avenir"
    let fontSize: CGFloat = 14

    let sensitivityDistance: CGFloat = 6
    let borderWidth: CGFloat = 1

    init(candidate: ObjectDetectionCandidate, withCenter: CGPoint ) {
        super.init(frame: CGRect(x: 0, y: 0, width: 0, height: 0))

        layer.borderWidth = borderWidth
        layer.backgroundColor = UIColor.black.withAlphaComponent(0.8).cgColor
        let passioSDK = PassioSDK.shared
        textColor = .black
        layer.borderColor = UIColor.black.cgColor
        let passioID = candidate.passioID
        let odetected = passioSDK.lookupPassioIDAttributesFor(passioID: passioID)?.name ?? passioID
        text = """
          \(candidate.confidence.roundDigits(afterDecimal: 2)) \(odetected)
        """
        font = UIFont(name: fontName, size: fontSize)
        // sizeToFit()
        let totalWidth: CGFloat = 180
        let totalHeight: CGFloat = 60.0
        frame = CGRect(x: withCenter.x - totalWidth/2, y: withCenter.y - totalHeight/2,
                       width: totalWidth, height: totalHeight)

        numberOfLines = 3
        backgroundColor = .white

    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
