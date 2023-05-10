//
//  MyLogViewController.swift
//  Passio App Module
//
//  Created by zvika on 2/12/19.
//  Copyright © 2023 Passiolife Inc. All rights reserved.
//

import UIKit
#if canImport(PassioNutritionAISDK)
import PassioNutritionAISDK
#endif
#if canImport(Charts)
import Charts
#endif

class MyLogViewController: UIViewController {

    @IBOutlet weak var tableViewFeed: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var buttonAddItem: UIButton!
    @IBOutlet weak var labelNoItems: UILabel!

    let passioSDK = PassioNutritionAI.shared
    let numberOfCellAbove = 2
    let refreshControl = UIRefreshControl()
    let connector = PassioInternalConnector.shared
    var userProfile = UserProfileModel()

var selectedMeal: MealLabel? {
        didSet {
            connector.mealLabel = selectedMeal
            tableViewFeed.reloadData()
        }
    }
    var dayLog = DayLog(date: Date()) {
        didSet(newValue) {
            labelNoItems.isHidden = !dayLog.records.isEmpty
            addButtonTitle(withDate: Date())
            tableViewFeed?.reloadData()
        }
    }
    var displayedRecords: [FoodRecord] {
        dayLog.getFoodRecordsByMeal(mealLabel: selectedMeal)
    }
    var dateSelector: DateSelectorUIView?

    @IBAction func showDateSelector(_ sender: Any) {
        if dateSelector == nil {
            let nib = UINib(nibName: "DateSelectorUIView", bundle: connector.bundleForModule)
            dateSelector = nib.instantiate(withOwner: self, options: nil).first as? DateSelectorUIView
            let screenSize = UIScreen.main.bounds.size
            let frameStart = CGRect(x: 0, y: -screenSize.width, width: screenSize.width, height: screenSize.width)
            dateSelector?.frame = frameStart
            dateSelector?.dateForPicker = dayLog.date
            dateSelector?.delegate = self
            self.dateSelector?.roundMyCornerWith(radius: 20)
            view.addSubview(dateSelector!)
            animateDateSelector(directions: .down)
        } else {
            animateDateSelector(directions: .upWards)
        }
    }

    enum SelectorDirections {
        case down, upWards
    }

    func animateDateSelector(directions: SelectorDirections) {
        let screenSize = UIScreen.main.bounds.size
        var frameEnd: CGRect
        switch directions {
        case .down:
            frameEnd = CGRect(x: 0, y: 0, width: screenSize.width, height: screenSize.width)
        case .upWards:
            frameEnd = CGRect(x: 0, y: -screenSize.width, width: screenSize.width, height: screenSize.width)
        }
        UIView.animateKeyframes(withDuration: 0.5, delay: 0, options: [.calculationModeLinear], animations: {
            // Add animations
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.5/0.5, animations: {
                self.dateSelector?.frame = frameEnd
            })
        }, completion: { _ in
            if directions == .upWards {
                self.dateSelector = nil
            }
        })
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        labelNoItems.text = "No food in log.\nPress Add Item below to start."
        connector.fetchUserProfile { (userProfile) in
            self.userProfile = userProfile ?? UserProfileModel()
        }
        customizeNavForModule(withBackButton: false)
        addMoreButton()
        addButtonTitle(withDate: Date())
        registerCellsAndTableDelegates()
        UISegmentedControl.appearance().setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.white],
                                                               for: .selected)
        UISegmentedControl.appearance().setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.black],
                                                               for: .normal)
    }

    func addMoreButton() {
        let progress = UIBarButtonItem(title: "More",
                                        style: .plain,
                                        target: self,
                                        action: #selector(showMoreMenu))
                self.navigationItem.setRightBarButtonItems([progress], animated: true)
                self.navigationItem.setLeftBarButton(nil, animated: false)
    }

    @objc func showMoreMenu() {
            let alert = UIAlertController(title: "Menu".localized,
                                          message: nil,
                                          preferredStyle: .actionSheet)
// #if canImport(Charts)
//            alert.addAction(UIAlertAction(title: "Progress".localized,
//                                          style: .default, handler: { _ in
//                let vc = MyProgressViewController()
//                vc.modalPresentationStyle = .fullScreen
//                self.present(vc, animated: true)
//            }))
// #endif
            alert.addAction(UIAlertAction(title: "Favorites".localized,
                                          style: .default, handler: { _ in
                let vc = MyFavoritesViewController()
                vc.modalPresentationStyle = .fullScreen
                vc.delegate  = self
                // self.present(vc, animated: true)
                self.navigationController?.pushViewController(vc, animated: true)
            }))
            alert.addAction(UIAlertAction(title: "Profile".localized,
                                          style: .default, handler: { _ in
                let vc = EditProfileViewController()
                vc.userProfile = self.userProfile
                // vc.dismmissToMyLog = true
                vc.modalPresentationStyle = .fullScreen
                self.present(vc, animated: true)
            }))
        if PassioNutritionAI.shared.availableVolumeDetectionModes.contains(VolumeDetectionMode.dualWideCamera) {
            alert.addAction(UIAlertAction(title: "Weight estimated food".localized, style: .default, handler: { _ in
                let vc = ListOfFoodViewController()
                self.navigationController?.pushViewController(vc, animated: true)
            }))
        }
        alert.addAction(UIAlertAction(title: "Developer Views".localized,
                                      style: .default, handler: { _ in
            let vc = EngineeringViewController()
            self.navigationController?.pushViewController(vc, animated: true)

        }))
        alert.addAction(UIAlertAction(title: "Cancel".localized,
                                      style: .cancel))
        present(alert, animated: true)
    }

    func addButtonTitle(withDate: Date) {
        let dateFormatterPrint = DateFormatter()
        dateFormatterPrint.dateFormat = "EEEE MMM dd yyyy"
        let newTitle = dateFormatterPrint.string(for: withDate) ?? "Today".localized
        let button = UIButton(type: .custom)
        button.frame = CGRect(x: 0, y: 0, width: 100, height: 40)
        button.setTitle(newTitle, for: .normal)
        button.addTarget(self, action: #selector(showDateSelector), for: .touchUpInside)
        navigationItem.titleView = button
        button.setTitleColor(.black, for: .normal)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setDayLogForSelectedDate()
    }

    func registerCellsAndTableDelegates() {
        tableViewFeed.delegate = self
        tableViewFeed.dataSource = self
        tableViewFeed.rowHeight = UITableView.automaticDimension
        tableViewFeed.estimatedRowHeight = 300
        refreshControl.addTarget(self, action: #selector(setDayLogForSelectedDate), for: .valueChanged)
        tableViewFeed.addSubview(refreshControl)
        CellMyLogNames.allCases.forEach {
            let cellName = $0.rawValue.capitalizingFirst()
            let cell = UINib(nibName: cellName, bundle: connector.bundleForModule)
            tableViewFeed.register(cell, forCellReuseIdentifier: cellName)
        }
    }

    @objc func setDayLogForSelectedDate() {
        setDayLogFor(date: dayLog.date)
    }

    func setDayLogFor(date: Date) {
        connector.fetchDayRecords(date: date) { (foodRecord) in
            self.dayLog = DayLog(date: date, records: foodRecord)
            self.addButtonTitle(withDate: date)
            self.tableViewFeed.reloadData()
            self.refreshControl.endRefreshing()
        }
    }

    @IBAction func actionAddItem(_ sender: UIButton) {

        let alert = UIAlertController(title: "Add Item".localized,
                                      message: nil,
                                      preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Quick-Food Scan".localized,
                                      style: .default, handler: { _ in
            let vc = FoodRecognitionViewController()
            vc.dismmissToMyLog = true
            vc.modalPresentationStyle = .fullScreen
           // vc.delegate = self
            self.present(vc, animated: true)
        }))
        alert.addAction(UIAlertAction(title: "Multi-Food Scan".localized,
                                      style: .default, handler: { _ in
            let vc = MultipleFoodViewController()
            vc.dismmissToMyLog = true
            vc.modalPresentationStyle = .fullScreen
           // vc.delegate  = self
            self.present(vc, animated: true)
        }))
        alert.addAction(UIAlertAction(title: "By Text Search".localized,
                                      style: .default, handler: { _ in
            let vc = TextSearchViewController()
            vc.dismmissToMyLog = true
            vc.modalPresentationStyle = .fullScreen
            vc.delegate = self
            self.present(vc, animated: true)
        }))
        alert.addAction(UIAlertAction(title: "From Favorites".localized,
                                      style: .default, handler: { _ in
            let vc = MyFavoritesViewController()
            vc.dismmissToMyLog = true
            vc.modalPresentationStyle = .fullScreen
            vc.delegate = self
            self.present(vc, animated: true)
        }))
        alert.addAction(UIAlertAction(title: "Cancel".localized,
                                      style: .cancel))
        present(alert, animated: true)
    }
}

extension MyLogViewController: FavoritesViewDelegate {
    func userSelectedFavorite(favorite: FoodRecord) {

    }

    func numberOfFavotires(number: Int) {

    }

    func userAddedToLog(foodRecord: FoodRecord) {
        dayLog.add(record: foodRecord)
        tableViewFeed.reloadData()
    }

}

extension MyLogViewController: TextSearchViewDelgate {
    func userSelectedFoodItemViaText(passioIDAndName: PassioIDAndName?) {
        if let passioID = passioIDAndName?.passioID,
           let pidAtt = passioSDK.lookupPassioIDAttributesFor(passioID: passioID) {
            let foodRecord = FoodRecord(passioIDAttributes: pidAtt,
                                        replaceVisualPassioID: nil,
                                        replaceVisualName: nil,
                                        scannedWeight: nil)
            connector.updateRecord(foodRecord: foodRecord, isNew: true)
            dayLog.add(record: foodRecord)
            tableViewFeed.reloadData()
        }
    }

}

extension MyLogViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        displayedRecords.count + numberOfCellAbove
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:

// #if canImport(Charts)
//            guard let cell = tableViewFeed.dequeueReusableCell(withIdentifier: "PassioChartsTableVCell",
//                                                               for: indexPath) as? PassioChartsTableVCell else {
//                                                                return UITableViewCell() }
//
//            let (calories, carbs, pro, fat) = getNutritionSummaryfor(foodRecords: displayedRecords)
//            cell.chartNutrition = customizeNutritionChart(chart: cell.chartNutrition,
//                                                          carbs: carbs,
//                                                          pro: pro,
//                                                          fat: fat,
//                                                          valuesOrPercent: valuesOrPercent)
//            cell.chartCalories = customizeCaloriesChart(chart: cell.chartCalories,
//                                                        calories: calories,
//                                                        dailyTarget: Double(userProfile.caloriesTarget),
//                                                        numberOfDays: 1,
//                                                        valuesOrPercent: .values)
//            cell.selectionStyle = .none
//            return cell
// #else
            let cell = UITableViewCell()
            cell.textLabel?.text = "Place holder for charts."
            cell.textLabel?.textAlignment = .center
           return cell
// #endif

        case 1:
            guard let cell = tableViewFeed.dequeueReusableCell(withIdentifier: "SegmentedTableViewCell",
                                                               for: indexPath) as? SegmentedTableViewCell else {
                                                                return UITableViewCell() }
            cell.segmented.removeAllSegments()
            var title: String
            var selectedSegment = 0
            for index in 0...4 {
                if index == 0 {
                    title = "AllDay".localized
                } else {
                    title = MealLabel.allValues[index - 1].rawValue.localized
                    if let ztitle = selectedMeal?.rawValue, title == ztitle.localized {
                        selectedSegment = index
                    }
                }
                cell.segmented.insertSegment(withTitle: title, at: index, animated: false)
            }
            cell.segmented.selectedSegmentIndex = selectedSegment
            cell.segmented.addTarget(self, action: #selector(segmentedChanged(segemented:)), for: .valueChanged)
            cell.selectionStyle = .none
            return cell
        default:
            guard let cell = tableViewFeed.dequeueReusableCell(withIdentifier: "IngredientHeaderTableViewCell",
                                                               for: indexPath) as? IngredientHeaderTableViewCell else {
                                                                return UITableViewCell()
            }

            let records = dayLog.getFoodRecordsByMeal(mealLabel: selectedMeal)
            let recordIndex = indexPath.row - numberOfCellAbove
            guard 0 <= recordIndex, recordIndex < records.count else {
                return UITableViewCell()
            }
            let foodRecord = records[recordIndex]
            cell.labelName.text = foodRecord.name.capitalized

            let quantity = foodRecord.selectedQuantity
            let title = foodRecord.selectedUnit.capitalized
            let weight = String(Int(foodRecord.computedWeight.value))
            let textAmount = quantity == Double(Int(quantity)) ? String(Int(quantity)) :
                String(quantity.roundDigits(afterDecimal: 1))
            let weightText = title == "g" ? "" : "(" + weight + " " + "g".localized + ") "
            cell.labelServing.text = textAmount + " " + title + " " + weightText

            var calStr = "0"
            let cal = foodRecord.totalCalories
            if 0 < cal, cal < 1e6 {
                calStr = String(Int(cal))
            }
            cell.labelCalories.text = "Calories".localized + ": " +  calStr
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
            cell.imageFood.roundMyCorner()
            cell.labelTime.text = foodRecord.mealLabel.rawValue
//            cell.insetBackground.backgroundColor = UIColor(named: Custom.insetBackgroundColor,
//                                                           in: connector.bundleForModule, compatibleWith: nil)
            cell.selectionStyle = .none
            return cell
        }
    }

    @objc func segmentedChanged(segemented: UISegmentedControl) {
        switch segemented.selectedSegmentIndex {
        case 0:
            selectedMeal = nil
        default:
            selectedMeal = MealLabel(rawValue: MealLabel.allValues[segemented.selectedSegmentIndex - 1].rawValue)
        }
    }

//    @objc func mealSelected(button: UIButton) {
//        switch button.tag {
//        case -1:
//            selectedMeal = nil
//        default:
//            selectedMeal = MealLabel(rawValue: MealLabel.allValues[button.tag].rawValue)
//        }
//    }

}

extension MyLogViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            break
        case 1:
            break
        default:
            let indexdjusted = indexPath.row - numberOfCellAbove
            guard indexdjusted >= 0, displayedRecords.count > indexdjusted  else { return }
            let record = displayedRecords[indexdjusted]
            navigateToEditor(foodRecord: record)
        }
    }

    func navigateToEditor(foodRecord: FoodRecord) {
        let editVC = EditRecordViewController()
        editVC.foodRecord = foodRecord
        self.navigationController?.pushViewController(editVC, animated: true)
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) ->
    UISwipeActionsConfiguration? {
        guard indexPath.row >= numberOfCellAbove else { return nil }
        let deleteItem = UIContextualAction(style: .destructive, title: "Delete".localized) {  (_, _, _) in
            let indexCorrected = indexPath.row - self.numberOfCellAbove
            guard self.displayedRecords.count > indexCorrected else { return }
            let record = self.displayedRecords[indexCorrected]
            self.connector.deleteRecord(foodRecord: record)
            self.dayLog.delete(record: record)
            self.tableViewFeed.reloadData()
        }

        let editItem = UIContextualAction(style: .normal, title: "Edit".localized) { (_, _, _) in
            let indexAdjusted = indexPath.row - self.numberOfCellAbove
            guard indexAdjusted >= 0, self.displayedRecords.count > indexAdjusted  else { return }
            let record = self.displayedRecords[indexAdjusted]
            self.navigateToEditor(foodRecord: record)
        }
        editItem.backgroundColor = UIColor(named: "CustomBase",
                                           in: connector.bundleForModule, compatibleWith: nil)

        let swipeActions = UISwipeActionsConfiguration(actions: [deleteItem, editItem])
        return swipeActions
    }

    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) ->
    UITableViewCell.EditingStyle {
        return indexPath.row > numberOfCellAbove ? .delete : .none
    }

}

extension MyLogViewController: DateSelectorUIViewDelegate {

    func removeDateSelector(remove: Bool) {
        animateDateSelector(directions: .upWards)
    }

    func dateFromPicker(date: Date) {
        connector.dateForLogging = date
        setDayLogFor(date: date)
    }

}
