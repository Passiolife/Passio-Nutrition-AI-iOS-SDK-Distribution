//
//  MealSelectionTableViewCell.swift
//  PassioAppModule
//
//  Created by Patrick Goley on 4/19/21.
//

import UIKit

protocol MealSelectionDelegate: AnyObject {

    func didChangeMealSelection(selection: MealLabel)
}

class MealSelectionTableViewCell: UITableViewCell {

    weak var delegate: MealSelectionDelegate?

    private var selectedButton: ColoredButton?

    @IBOutlet weak var breakfastButton: ColoredButton!
    @IBOutlet weak var snackButton: ColoredButton!
    @IBOutlet weak var dinnerButton: ColoredButton!
    @IBOutlet weak var lunchButton: ColoredButton!

    @IBOutlet weak var insetBackgroundView: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        styleButton(breakfastButton, title: "Breakfast", roundedCorners: [.layerMinXMinYCorner, .layerMinXMaxYCorner])
        styleButton(lunchButton, title: "Lunch")
        styleButton(dinnerButton, title: "Dinner")
        styleButton(snackButton, title: "Snack", roundedCorners: [.layerMaxXMinYCorner, .layerMaxXMaxYCorner])
        insetBackgroundView.roundMyCornerWith(radius: Custom.insetBackgroundRadius)
    }

    func setMealSelection(_ mealLabel: MealLabel) {

        let selectedButton: ColoredButton
        switch mealLabel {
        case .breakfast:
            selectedButton = breakfastButton
        case .lunch:
            selectedButton = lunchButton
        case .dinner:
            selectedButton = dinnerButton
        case .snack:
            selectedButton = snackButton
        }

        self.selectedButton?.isSelected = false
        selectedButton.isSelected = true
        self.selectedButton = selectedButton
    }

    func styleButton(_ button: ColoredButton, title: String, roundedCorners: CACornerMask = []) {

        button.layer.maskedCorners = roundedCorners
        if !roundedCorners.isEmpty {
            button.cornerRadius = 15
        }

        button.borderColor = .defaultBlue
        button.borderWidth = 1

        // normal state
        button.setAttributedTitle(NSAttributedString(string: title, attributes: [
            .font: UIFont.avenirMedium(size: 15),
            .foregroundColor: UIColor.defaultBlue
        ]), for: .normal)
        button.setBackgroundColor(.white, for: .normal)

        // selected state
        let selectedAttributes = NSAttributedString(string: title, attributes: [
            .font: UIFont.avenirMedium(size: 15),
            .foregroundColor: UIColor.white
        ])
        button.setAttributedTitle(selectedAttributes, for: .highlighted)
        button.setAttributedTitle(selectedAttributes, for: .selected)
        button.setBackgroundColor(.defaultBlue, for: .selected)
        button.setBackgroundColor(.defaultBlue, for: .highlighted)
    }

    @IBAction func mealButtonPressed(_ sender: ColoredButton) {

        selectedButton?.isSelected = false
        sender.isSelected = true
        selectedButton = sender

        let meal: MealLabel
        switch sender {
        case breakfastButton: meal = .breakfast
        case lunchButton: meal = .lunch
        case dinnerButton: meal = .dinner
        case snackButton: meal = .snack
        default:
            return
        }

        delegate?.didChangeMealSelection(selection: meal)
    }
}
