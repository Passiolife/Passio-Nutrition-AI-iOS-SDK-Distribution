//
//  AmountQuickMiniTableViewCell.swift
//  PassioPassport
//
//  Created by zvika on 2/1/19.
//  Copyright © 2023 Passiolife Inc. All rights reserved.
//

import UIKit

class AmountQuickMiniTableViewCell: UITableViewCell {

    @IBOutlet weak var collectionAmounts: UICollectionView! {
        didSet {
            CellNameCollections.allCases.forEach {
                let cellName = $0.rawValue.capitalizingFirst()
                let cell = UINib(nibName: cellName, bundle: PassioInternalConnector.shared.bundleForModule)
                collectionAmounts.register(cell, forCellWithReuseIdentifier: cellName)
            }
        }
    }
    @IBOutlet weak var insetBackground: UIView!

    func setCollectionViewDataSourceDelegate(dataSourceDelegate: UICollectionViewDataSource & UICollectionViewDelegate,
                                             forRow row: Int) {
        collectionAmounts.delegate = dataSourceDelegate
        collectionAmounts.dataSource = dataSourceDelegate
        collectionAmounts.tag = row
        collectionAmounts.reloadData()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
//        insetBackground.roundMyCornerWith(radius: Custom.insetBackgroundRadius)
         insetBackground.roundMyCornerWith(radius: Custom.insetBackgroundRadius, upper: false, down: true)
    }
}
