//
//  ListOfFoodViewController.swift
//  BaseApp
//
//  Created by Zvika on 1/27/22.
//  Copyright © 2023 Passio Inc. All rights reserved.
//

import UIKit
#if canImport(PassioNutritionAISDK)
import PassioNutritionAISDK
#endif

class ListOfFoodViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!

    let passioSDK = PassioNutritionAI.shared
    let bundlePod = PassioInternalConnector.shared.bundleForModule

    var canRunVolume: Bool {
        passioSDK.availableVolumeDetectionModes.contains(VolumeDetectionMode.dualWideCamera)
    }

    var passioIDs = [PassioID]()

    override func viewDidLoad() {
        super.viewDidLoad()
        let cell = UINib(nibName: "FoodVolumeTableViewCell", bundle: bundlePod)
        tableView.register(cell, forCellReuseIdentifier: "FoodVolumeTableViewCell")
        tableView.dataSource = self
        passioIDs = passioSDK.listFoodEnabledForAmountEstimation().sorted()

        // lineItmes.sort {$0.name < $1.name}

        tableView.reloadData()
    }

}

extension ListOfFoodViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        if canRunVolume {
            title = "Total of \(passioIDs.count) foods"
            return passioIDs.count
        } else {
            return 0
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "FoodVolumeTableViewCell",
                                                       for: indexPath) as? FoodVolumeTableViewCell else {
            return UITableViewCell()
        }

        guard canRunVolume else {
            cell.imageFood.image = nil
            cell.nameLabel.text = "This iPhone doesn't support Weight Estimation"
            return cell
        }

        guard passioIDs.count > indexPath.row else {
            return UITableViewCell()
        }
        let passioID = passioIDs[indexPath.row]
        cell.nameLabel.text = passioSDK.lookupNameFor(passioID: passioID) ?? "no name"
        cell.imageFood.image = nil
        cell.passioIDForCell = passioID
        cell.imageFood.loadPassioIconBy(passioID: passioID,
                                        entityType: .item) { passioIDForImage, image in
            if passioIDForImage == cell.passioIDForCell {
                DispatchQueue.main.async {
                    cell.imageFood.image = image
                }
            }
        }
    cell.selectionStyle = .none
    return cell
}

}
