//
//  AlternativesMicroTableViewCell.swift
//  PassioPassport
//
//  Created by zvika on 2/1/19.
//  Copyright © 2023 Passiolife Inc. All rights reserved.
//

import UIKit

class AlternativesMicroTableViewCell: UITableViewCell {

    @IBOutlet weak var insetBackground: UIView!

    @IBOutlet private weak var collectionAlternatives: UICollectionView! {
        didSet {
            CellNameCollections.allCases.forEach {
                let cellName = $0.rawValue.capitalizingFirst()
                let cell = UINib(nibName: cellName, bundle: PassioInternalConnector.shared.bundleForModule)
                collectionAlternatives.register(cell, forCellWithReuseIdentifier: cellName)
            }
        }
    }
    @IBOutlet weak var collectionViewHeight: NSLayoutConstraint!

    override func layoutSubviews() {
        super.layoutSubviews()
        insetBackground.roundMyCornerWith(radius: Custom.insetBackgroundRadius)
    }

    func setCollectionViewDataSourceDelegate(dataSourceDelegate: UICollectionViewDataSource & UICollectionViewDelegate,
                                             forRow row: Int) {
        collectionAlternatives.delegate = dataSourceDelegate
        collectionAlternatives.dataSource = dataSourceDelegate
        collectionAlternatives.tag = row
        collectionAlternatives.reloadData()
    }

}
