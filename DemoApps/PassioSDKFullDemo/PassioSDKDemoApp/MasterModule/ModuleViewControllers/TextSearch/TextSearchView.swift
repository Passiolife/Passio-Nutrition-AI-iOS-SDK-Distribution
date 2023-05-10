//
//  TextSearchView.swift
//  PassioPassport
//
//  Created by zvika on 4/1/19.
//  Copyright © 2023 Passiolife Inc. All rights reserved.
//

import UIKit
#if canImport(PassioNutritionAISDK)
import PassioNutritionAISDK
#endif

protocol TextSearchViewDelgate: AnyObject {
    func userSelectedFoodItemViaText(passioIDAndName: PassioIDAndName?)
}

class TextSearchView: UIView {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableHight: NSLayoutConstraint!

    let passioSDK = PassioNutritionAI.shared
    let noFood = " is not in the database".localized
    let searchController = UISearchController(searchResultsController: nil)
    let bundlePod = PassioInternalConnector.shared.bundleForModule

    weak var delegate: TextSearchViewDelgate?
    var foodItems = [PassioIDAndName]()
    var filteredFoodItems = [PassioIDAndName]()

    override func awakeFromNib() {
        super.awakeFromNib()
        // TableView
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableView.automaticDimension
        let bundle = PassioInternalConnector.shared.bundleForModule
        let cell = UINib(nibName: "TextSearchTableViewCell", bundle: bundle)
        tableView.register(cell, forCellReuseIdentifier: "TextSearchTableViewCell")

        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.sizeToFit()
        searchController.searchBar.placeholder = "Search for ".localized
        searchController.searchBar.delegate = self

        let titleAttribures = [NSAttributedString.Key.foregroundColor: UIColor.black]
        UIBarButtonItem.appearance(whenContainedInInstancesOf:
            [UISearchBar.self]).setTitleTextAttributes(titleAttribures,
                                                       for: .normal)
        if #available(iOS 13, *) {
            searchController.searchBar.searchTextField.textColor = .black
            searchController.searchBar.searchTextField.leftView?.tintColor = .black
            searchController.searchBar.searchTextField.rightView?.tintColor = .black
            searchController.searchBar.searchTextField.backgroundColor = UIColor(named: "PassioLowContrast", in: bundlePod, compatibleWith: nil)
            searchController.searchBar.barTintColor = UIColor(named: "PassioMedContrast", in: bundlePod, compatibleWith: nil)
        }
        searchController.searchBar.keyboardAppearance = .dark
        tableView.tableHeaderView = searchController.searchBar
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)),
                                               name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)),
                                               name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver( UIResponder.keyboardWillShowNotification)
        NotificationCenter.default.removeObserver( UIResponder.keyboardWillHideNotification)
    }

    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        delayClosureExecutionFor(seconds: 0.3) {
            self.searchController.searchBar.becomeFirstResponder()
        }
        delayClosureExecutionFor(seconds: 0.5) {
            self.searchController.searchBar.becomeFirstResponder()
        }
        delayClosureExecutionFor(seconds: 1) {
            self.searchController.searchBar.becomeFirstResponder()
        }
    }

    func delayClosureExecutionFor(seconds: Double, closure: @escaping () -> Void) {
        let when = DispatchTime.now() + seconds
        DispatchQueue.main.asyncAfter(deadline: when, execute: closure)
    }

    func searchBarIsEmpty() -> Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }

    func isFiltering() -> Bool {
        let searchBarScopeIsFiltering = searchController.searchBar.selectedScopeButtonIndex != 0
        return searchController.isActive && (!searchBarIsEmpty() || searchBarScopeIsFiltering)
    }

    func userSelected(row: Int) {
        var passioIDAndName: PassioIDAndName
        if isFiltering() {
            passioIDAndName = filteredFoodItems[row]
        } else {
            passioIDAndName = foodItems[row]
        }
        dissmissThisView(passioIDAndName: passioIDAndName)
    }

    func dissmissThisView(passioIDAndName: PassioIDAndName? = nil) {
        searchController.resignFirstResponder()
        searchController.isActive = false
        delegate?.userSelectedFoodItemViaText(passioIDAndName: passioIDAndName)
    }

    func filterContentForSearchText(_ searchText: String ) {
        guard searchText.count > 0 else {
            filteredFoodItems = []
            tableView.reloadData()
            return
        }
       // let startTime = Date()
        passioSDK.searchForFood(byText: searchText) { [self] passioIDAndNames in
            if passioIDAndNames.isEmpty {
                self.filteredFoodItems = [PassioIDAndName(passioID: "", name: searchText + self.noFood)]
            } else {
                self.filteredFoodItems = passioIDAndNames
            }
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }

    }

    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardRectValue = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as?
            NSValue)?.cgRectValue {
            let constant = (UIApplication.shared.delegate?.window??.safeAreaInsets.top ?? 00) +
                (UIApplication.shared.delegate?.window??.safeAreaInsets.bottom ?? 00)
            tableHight.constant = frame.height - keyboardRectValue.height + constant - 40
            self.tableView.layoutIfNeeded()
        }
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        tableHight.constant = frame.height
        self.tableView.layoutIfNeeded()
    }

}

extension TextSearchView: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchBarIsEmpty() {
            return 0
        }
        if isFiltering() {
            return filteredFoodItems.count
        }
        return foodItems.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "TextSearchTableViewCell",
                                                       for: indexPath) as? TextSearchTableViewCell else {
            return UITableViewCell()
        }
        var food: PassioIDAndName
        if isFiltering(), filteredFoodItems.count > indexPath.row {
            food = filteredFoodItems[indexPath.row]
        } else if foodItems.count > indexPath.row {
            food = foodItems[indexPath.row]
        } else {
            print("Out of Range ************ \(indexPath.row)")
            return UITableViewCell()
        }
        if food.name.contains(noFood) {
            cell.imagePlus.isHidden = true
            cell.imageFood.image = nil
        } else {
            cell.imagePlus.isHidden = false
            cell.passioIDForCell = food.passioID
            cell.imageFood.loadPassioIconBy(passioID: food.passioID,
                                            entityType: .item) { passioIDForImage, image in
                if passioIDForImage == cell.passioIDForCell {
                    DispatchQueue.main.async {
                        cell.imageFood.image = image
                    }
                }
            }
        }
        cell.nameLabel.text = food.name.capitalized
        cell.setSelected(false, animated: false)
        cell.selectionStyle = .none
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? TextSearchTableViewCell {
            cell.setSelected(true, animated: true)
            userSelected(row: indexPath.row)
        }
    }

}

extension TextSearchView: UISearchBarDelegate {

    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        filterContentForSearchText(searchBar.text!)
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        dissmissThisView()
    }

}

extension TextSearchView: UISearchResultsUpdating {

    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }

}
