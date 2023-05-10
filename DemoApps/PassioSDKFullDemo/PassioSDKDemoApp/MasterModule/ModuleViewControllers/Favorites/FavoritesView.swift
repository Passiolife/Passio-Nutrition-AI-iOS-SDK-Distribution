//
//  FavoritesView.swift
//  Passio App Module
//
//  Created by zvika on 4/9/19.
//  Copyright © 2023 Passiolife Inc. All rights reserved.
//

import UIKit
#if canImport(PassioNutritionAISDK)
import PassioNutritionAISDK
#endif

protocol FavoritesViewDelegate: AnyObject {
    func userSelectedFavorite(favorite: FoodRecord)
    func numberOfFavotires(number: Int)
    func userAddedToLog(foodRecord: FoodRecord)
}

class FavoritesView: UIView {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    let refreshControl = UIRefreshControl()
    let connector = PassioInternalConnector.shared

    weak var delegate: FavoritesViewDelegate?
    var favorites = [FoodRecord]()
    override func awakeFromNib() {
        super.awakeFromNib()
        let cell = UINib(nibName: "FavoriteTableViewCell",
                         bundle: connector.bundleForModule)
        tableView.register(cell, forCellReuseIdentifier: "FavoriteTableViewCell")
        tableView.delegate = self
        tableView.dataSource = self
        refreshControl.addTarget(self,
                                 action: #selector(getFavoritesFromConnector),
                                 for: .valueChanged )
        tableView.addSubview(refreshControl)
        getFavoritesFromConnector()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        tableView.reloadData()
    }

    @objc func getFavoritesFromConnector() {
        activityIndicator.startAnimating()
        connector.fetchFavorites { (records) in
            self.favorites = records.sorted {$0.createdAt > $1.createdAt }
            self.activityIndicator.stopAnimating()
            self.tableView.reloadData()
            self.delegate?.numberOfFavotires(number: self.favorites.count)
        }
        self.refreshControl.endRefreshing()
    }

    var addedToFavorites = -1
}
extension FavoritesView: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return favorites.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "FavoriteTableViewCell",
                                                       for: indexPath) as? FavoriteTableViewCell else {
                                                        return UITableViewCell()
        }
        let favorite = favorites[indexPath.row]
        cell.nameLabel.text = favorite.name.capitalized
        cell.nutritionLabel.text = favorite.nutritionLabel
        // cell.imageFood.image = favorite.icon
        cell.passioIDForCell = favorite.passioID
        cell.imageFood.loadPassioIconBy(passioID: favorite.passioID,
                                        entityType: favorite.entityType) { passioIDForImage, image in
            if passioIDForImage == cell.passioIDForCell {
                DispatchQueue.main.async {
                    cell.imageFood.image = image
                }
            }
        }
        cell.imageFood.roundMyCorner()
        cell.buttonAddToLog.addTarget(self, action: #selector(addFoodToLog(button:)), for: .touchUpInside)
        cell.buttonAddToLog.tag = indexPath.row

        if indexPath.row == addedToFavorites {
            cell.buttonAddToLog.isHidden = true
        } else {
            cell.buttonAddToLog.isHidden = false
        }
        cell.selectionStyle = .none
        return cell
    }

    @objc func addFoodToLog(button: UIButton) {
        var newFoodRecord = favorites[button.tag]
        newFoodRecord.uuid = UUID().uuidString
        newFoodRecord.createdAt = Date()
        connector.updateRecord(foodRecord: newFoodRecord, isNew: true)
        addedToFavorites = button.tag
        tableView.reloadData()
        delegate?.userAddedToLog(foodRecord: newFoodRecord)
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { (_) in
            self.addedToFavorites = -1
            self.tableView.reloadData()
        }
    }

}

extension FavoritesView: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let favorite = favorites[indexPath.row]
        delegate?.userSelectedFavorite(favorite: favorite)
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) ->
        UISwipeActionsConfiguration? {
        let deleteItem = UIContextualAction(style: .destructive, title: "Delete".localized) {  (_, _, _) in
            let favorite = self.favorites.remove(at: indexPath.row)
            self.connector.deleteFavorite(foodRecord: favorite)
            self.getFavoritesFromConnector()
            self.tableView.reloadData()
            self.refreshControl.endRefreshing()
        }
        let swipeActions = UISwipeActionsConfiguration(actions: [deleteItem])
        return swipeActions
    }

    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) ->
        UITableViewCell.EditingStyle {
        return .delete
    }

}
