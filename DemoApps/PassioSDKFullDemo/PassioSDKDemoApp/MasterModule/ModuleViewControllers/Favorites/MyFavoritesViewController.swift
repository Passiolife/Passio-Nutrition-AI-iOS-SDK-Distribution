//
//  MyFavoritesViewController.swift
//  Passio App Module
//
//  Created by zvika on 4/9/19.
//  Copyright © 2023 Passiolife Inc. All rights reserved.
//

import UIKit
#if canImport(PassioNutritionAISDK)
import PassioNutritionAISDK
#endif

class MyFavoritesViewController: UIViewController {

    @IBOutlet weak var closeButton: UIButton!
    var favoriteView: FavoritesView?
    weak var delegate: FavoritesViewDelegate?

    var dismmissToMyLog = false

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "TitleFavorites".localized
        let nib = UINib(nibName: "FavoritesView", bundle: nil) // PassioInternalConnector.shared.bundleForModule)
        favoriteView = nib.instantiate(withOwner: self, options: nil).first as? FavoritesView
        favoriteView?.delegate = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let favoriteView = favoriteView else { return}
        let newFrame = CGRect(x: view.bounds.origin.x,
                               y: view.bounds.origin.y+44+50,
                               width: view.bounds.width,
                               height: view.bounds.height-44-50)
        favoriteView.frame = newFrame
        favoriteView.getFavoritesFromConnector()
        view.addSubview(favoriteView)
        if navigationController == nil {
            closeButton.setTitle("", for: .normal)
            closeButton.isHidden = false
        } else {
            closeButton.isHidden = true
        }
    }

    func alertUserNoFavorits() {
        let alert = UIAlertController(title: "Nofavorites".localized,
                                      message: "SaveFavorites".localized, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK".localized, style: .default) { _ in
            self.navigationController?.popViewController(animated: true)
        }
        alert.addAction(action)
        present(alert, animated: true)
    }
//
//    override  func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        favoriteView?.getFavoritesFromConnector()
//    }

    @IBAction func dissmiss(_ sender: Any) {
        dismiss(animated: true)
    }

}

extension MyFavoritesViewController: FavoritesViewDelegate {

    func userAddedToLog(foodRecord: FoodRecord) {
        delegate?.userAddedToLog(foodRecord: foodRecord)
        if dismmissToMyLog {
            dismiss(animated: true)
        } else {
            displayAdded(withText: "Item added to Log" )
//            title = "Added to log".localized// "\(foodRecord.name.capitalized) was added"
//             Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { (_) in
//                self.title =  "TitleFavorites".localized
//            }
        }
    }

    func displayAdded(withText: String) {
        let width: CGFloat = 200
        let height: CGFloat = 40
        let fromButton: CGFloat = 100
        let frame = CGRect(x: (view.bounds.width - width)/2,
                           y: view.bounds.height - fromButton,
                           width: width,
                           height: height)
        let addedToLog = AddedToLogView(frame: frame, withText: withText)
        view.addSubview(addedToLog)
        addedToLog.removeAfter(withDuration: 1, delay: 1)
    }

    func userSelectedFavorite(favorite: FoodRecord) {
        let editVC = EditRecordViewController()
        editVC.foodRecord = favorite
        editVC.isEditingFavorite = true
        navigationController?.pushViewController(editVC, animated: true)
    }

    func numberOfFavotires(number: Int) {
        if number < 1 {
            alertUserNoFavorits()
        }
    }

}
