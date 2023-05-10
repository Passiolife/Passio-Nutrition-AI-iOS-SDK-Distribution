//
//  NutritionNavigator.swift
//  BaseApp
//
//  Created by zvika on 3/10/21.
//  Copyright © 2023 Passio Inc. All rights reserved.
//

import UIKit
#if canImport(PassioNutritionAISDK)
import PassioNutritionAISDK
#endif

protocol NutritionBrowserDelegate: AnyObject {
    func userSelectedFromNBrower(foodRecord: FoodRecord?)
    func userCancelledNBrowser(originalRecord: FoodRecord?)
}

class NutritionBrowserView: UIView {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var buttonCancel: UIButton!
    @IBOutlet weak var buttonDefault: UIButton!
    @IBOutlet weak var buttonSelect: UIButton!

    let passioSDK = PassioNutritionAI.shared
    let connector = PassioInternalConnector.shared
    let bundlePod = PassioInternalConnector.shared.bundleForModule
    let numberOfTopRows = 1

    weak var delegate: NutritionBrowserDelegate?

    var foodRecord: FoodRecord? {
        willSet {
            if foodRecord == nil {
                originalRecord = foodRecord
            }
        }
        didSet {
            setChildrenSiblings()
        }
    }
    var originalRecord: FoodRecord?
    var childrenSiblings: [PassioAlternative]?

    override func awakeFromNib() {
        super.awakeFromNib()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.allowsSelection = true
        tableView.estimatedRowHeight = 140

//        let image = UIImage(named: "bttn_bg",
//                            in: bundlePod,
//                            compatibleWith: nil)
//        buttonCancel?.setBackgroundImage(image, for: .normal)
        buttonCancel?.setTitle( "Cancel", for: .normal)
        buttonCancel?.roundMyCornerWith(radius: Custom.buttonCornerRadius)

        buttonDefault?.setTitle("Default", for: .normal)
//        buttonDefault?.setBackgroundImage(image, for: .normal)
        buttonDefault?.roundMyCornerWith(radius: Custom.buttonCornerRadius)
        buttonDefault?.isHidden = true

        buttonSelect?.setTitle( "Select", for: .normal)
//        buttonSelect?.setBackgroundImage(image, for: .normal)
        buttonSelect?.roundMyCornerWith(radius: Custom.buttonCornerRadius)

        CellNamesForNavigator.allCases.forEach {
            let cellName = $0.rawValue.capitalizingFirst()
            let cell = UINib(nibName: cellName, bundle: bundlePod)
            tableView.register(cell, forCellReuseIdentifier: cellName)
        }
    }

    enum CellNamesForNavigator: String, CaseIterable {
        case nBHeaderTableViewCell,
             nBGroupTableViewCell
    }

    @IBAction func actionCancel(_ sender: UIButton) {
        delegate?.userCancelledNBrowser(originalRecord: originalRecord)
    }

    @IBAction func actionSelect(_ sender: UIButton) {
        delegate?.userSelectedFromNBrower(foodRecord: foodRecord)
    }

}

extension NutritionBrowserView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let childrenSiblings = childrenSiblings else {
            return 0
        }
        return numberOfTopRows + childrenSiblings.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellName = getCellNameFor(indexPath: indexPath)
        switch cellName {
        case .nBHeaderTableViewCell:
            return getNBHeaderTableViewCell(cellForRowAt: indexPath)
        case .nBGroupTableViewCell:
            return getNBGroupTableViewCell(cellForRowAt: indexPath)
        }
    }

    func getCellNameFor(indexPath: IndexPath) -> CellNamesForNavigator {
        switch indexPath.row {
        case 0:
            return .nBHeaderTableViewCell
        default:
            return .nBGroupTableViewCell
        }
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let nib = UINib(nibName: "FoodHeaderFullTableViewCell", bundle: bundlePod)
        guard let cell = nib.instantiate(withOwner: self, options: nil).first as? FoodHeaderFullTableViewCell,
              let foodRecord = foodRecord else {
            return UIView()
        }
        let foodHeader = FoodHeaderModel(foodRecord: foodRecord)
        cell.iconScannedAmount.isHidden = true
        cell.labelName.text = foodHeader.labelName
        cell.labelServing.text = foodHeader.labelServing
        cell.calories.text = foodHeader.calories
        cell.carbs.text = foodHeader.carbs
        cell.protein.text = foodHeader.protein
        cell.fat.text = foodHeader.fat

        cell.labelCal.text = foodHeader.labelCal
        cell.labelCarbs.text = foodHeader.labelCarbs
        cell.labelProtein.text = foodHeader.labelProtein
        cell.lableFat.text = foodHeader.lableFat
        // cell.imageFood.image = foodRecord.icon
        cell.passioIDForCell = foodRecord.passioID

        cell.imageFood.loadPassioIconBy(passioID: foodRecord.passioID,
                                        entityType: foodRecord.entityType) { passioIDForImage, image in
            if passioIDForImage == cell.passioIDForCell {
                DispatchQueue.main.async {
                    cell.imageFood.image = image
                }
            }
        }
        cell.imageFood.isUserInteractionEnabled = false
        cell.buttonShowAmounts.isHidden = true
        cell.imageFood.roundMyCorner()
        cell.selectionStyle = .none
        cell.insetBackground.backgroundColor = UIColor(named: Custom.insetBackgroundColor,
                                                       in: bundlePod, compatibleWith: nil)
        cell.insetBackground.roundMyCornerWith(radius: Custom.insetBackgroundRadius)
        return cell.contentView
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 140
    }

}

extension NutritionBrowserView: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let foodRecord = foodRecord,
              //   indexPath.row > 1,
              let childrenSiblings = childrenSiblings,
              indexPath.row < childrenSiblings.count + numberOfTopRows  else { return }
        if indexPath.row == 0 {
           goUpTheTree()
        } else {
            let passioID = childrenSiblings[indexPath.row - numberOfTopRows].passioID
            if let pAtt = passioSDK.lookupPassioIDAttributesFor(passioID: passioID) {
                let newFoodRecord = FoodRecord(passioIDAttributes: pAtt,
                                               replaceVisualPassioID: foodRecord.visualPassioID,
                                               replaceVisualName: foodRecord.visualName)
                self.foodRecord = newFoodRecord
                return
            }
        }
    }
}

extension NutritionBrowserView { // Cells

    func getNBHeaderTableViewCell (cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "NBHeaderTableViewCell",
                                                       for: indexPath) as? NBHeaderTableViewCell,
            let foodRecord = foodRecord else {
                return UITableViewCell()
        }
        cell.labelHeader.textColor = .black
        if foodRecord.parents?.first != nil {
            cell.buttonUp.setImage(UIImage(named: "chev_up"), for: .normal)
            cell.labelHeader.text = ""// "Go up"
        } else {
            cell.buttonUp.setImage(nil, for: .normal)
            cell.labelHeader.text =  "No More Up"
        }
        if childrenSiblings?.count  == 0 {
            cell.labelHeader.text =  "Go Up"
        }
        cell.buttonUp.addTarget(self, action: #selector(goUpTheTree), for: .touchUpInside)
        cell.roundMyCornerWith(radius: Custom.insetBackgroundRadius)
        cell.contentView.backgroundColor = UIColor(named: Custom.insetBackgroundColor,
                                                   in: bundlePod, compatibleWith: nil)
        return cell
    }

    @objc func goUpTheTree() {
        if let parent = foodRecord?.parents?.first,
           let pAtt = passioSDK.lookupPassioIDAttributesFor(passioID: parent.passioID) {
            let newFoodRecord = FoodRecord(passioIDAttributes: pAtt,
                                           replaceVisualPassioID: foodRecord?.visualPassioID,
                                           replaceVisualName: foodRecord?.visualName)
            self.foodRecord = newFoodRecord
        }
    }

    func getNBGroupTableViewCell (cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "NBGroupTableViewCell",
                                                       for: indexPath) as? NBGroupTableViewCell,
              let childrenSiblings = childrenSiblings,
              childrenSiblings.count > (indexPath.row - numberOfTopRows) else {
            return UITableViewCell()
        }
        let passioAlt = childrenSiblings[indexPath.row - numberOfTopRows]
        var childrenCount = 0
        if let childern =  foodRecord?.children {
            childrenCount = childern.count
        }
        let isSibling  = ((indexPath.row - childrenCount - numberOfTopRows) < 0) ? false : true
        guard let pAtt = passioSDK.lookupPassioIDAttributesFor(passioID: passioAlt.passioID) else {
            return UITableViewCell()
        }
        if pAtt.entityType == .group {
            cell.arrowDown.isHidden = false
        } else {
            cell.arrowDown.isHidden = true
        }

        if isSibling {
            cell.labelName.textColor = .gray
            cell.labelName.text = "   " + pAtt.name.capitalized
        } else {
            cell.labelName.textColor = .black
            cell.labelName.text = pAtt.name.capitalized
        }
        cell.roundMyCornerWith(radius: Custom.insetBackgroundRadius)
        cell.contentView.backgroundColor = UIColor(named: Custom.insetBackgroundColor,
                                                   in: bundlePod, compatibleWith: nil)
        return cell
    }

    func setChildrenSiblings() {
        guard let foodRecord = foodRecord else {
            return
        }
        childrenSiblings = (foodRecord.children ?? []) + (foodRecord.siblings ?? [])
        tableView.reloadWithAnimations()
        tableView.scrollToRow(at: IndexPath(item: 0, section: 0), at: .top, animated: true)
    }

}
