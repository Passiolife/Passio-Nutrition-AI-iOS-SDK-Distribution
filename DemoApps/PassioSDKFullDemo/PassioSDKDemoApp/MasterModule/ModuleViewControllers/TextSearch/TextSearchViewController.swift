//
//  TextSearchViewController.swift
//  SDKApp
//
//  Created by zvika on 1/16/19.
//  Copyright © 2023 Passio Inc. All rights reserved.
//

import UIKit
#if canImport(PassioNutritionAISDK)
import PassioNutritionAISDK
#endif

class TextSearchViewController: UIViewController {

    @IBOutlet weak var placementView: UIView!
    var textSearchView: TextSearchView!
    weak var delegate: TextSearchViewDelgate?
    let bundlePod = PassioInternalConnector.shared.bundleForModule

    var dismmissToMyLog = false

    override func viewDidLoad() {
        super.viewDidLoad()
        let nib = UINib(nibName: "TextSearchView", bundle: bundlePod)
        textSearchView = nib.instantiate(withOwner: self, options: nil).first as? TextSearchView
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        textSearchView.delegate = self
        textSearchView.frame = placementView.frame
        view.addSubview(textSearchView)
    }

}

extension TextSearchViewController: TextSearchViewDelgate {

    func userSelectedFoodItemViaText(passioIDAndName: PassioIDAndName?) {
        delegate?.userSelectedFoodItemViaText(passioIDAndName: passioIDAndName)
        if dismmissToMyLog {
            dismiss(animated: true)
        }
    }

}
