//
//  PassioInternalConnector.swift
//  BaseApp
//
//  Created by zvika on 1/23/20.
//  Copyright © 2023 Passio Inc. All rights reserved.//

import UIKit
#if canImport(PassioNutritionAISDK)
import PassioNutritionAISDK
#endif

public protocol PassioConnector: AnyObject {
    // UsrProfile
    func updateUserProfile(userProfile: UserProfileModel)
    func fetchUserProfile(completion: @escaping (UserProfileModel?) -> Void)
    // Records
    func updateRecord(foodRecord: FoodRecord, isNew: Bool)
    func deleteRecord(foodRecord: FoodRecord)
    func fetchDayRecords(date: Date, completion: @escaping ([FoodRecord]) -> Void)
    // Favorites
    func updateFavorite(foodRecord: FoodRecord)
    func deleteFavorite(foodRecord: FoodRecord)
    func fetchFavorites(completion: @escaping ([FoodRecord]) -> Void)
    // Photos
    // var passioKeyForSDK: String { get }
    var bundleForModule: Bundle { get }
    var offsetFoodEditor: CGFloat { get }
}

public class PassioInternalConnector {
    // MARK: Shared Object
    private init() {}

    internal var dateForLogging: Date?
    internal var mealLabel: MealLabel?

    public class var shared: PassioInternalConnector {
        if Static.instance == nil {
            Static.instance = PassioInternalConnector()
        }
        return Static.instance!
    }

    public func shutDown() {
        PassioNutritionAI.shared.shutDownPassioSDK()
        passioExternalConnector = nil
        Static.instance = nil
    }

    private struct Static {
        fileprivate static var instance: PassioInternalConnector?
    }

    weak var passioExternalConnector: PassioConnector?
    var isInNavController = true

    public func startPassioAppModule(passioExternalConnector: PassioConnector,
                                     presentingViewController: UIViewController,
                                     withDismissAnimation: Bool,
                                     passioConfiguration: PassioConfiguration,
                                     completion: @escaping (PassioStatus) -> Void) {
        self.passioExternalConnector = passioExternalConnector
        if PassioNutritionAI.shared.status.mode == .isReadyForDetection /*PassioNutritionAI.shared.status.mode == .isReadyForNutrition ||*/ {
            startModule(presentingViewController: presentingViewController)
        } else if PassioNutritionAI.shared.status.mode == .notReady {
            PassioNutritionAI.shared.configure(passioConfiguration: passioConfiguration) { (_) in
                DispatchQueue.main.async {
                    self.startModule( presentingViewController: presentingViewController)
                }
            }
        }
    }

    private func startModule(dismisswithAnimation: Bool = false,
                             presentingViewController: UIViewController) {
        var vc = UIViewController()
        // let keyForDef = "TutorialWasDisplayed202201"
        vc = MyLogViewController()
        if let navController = presentingViewController.navigationController {
            navController.pushViewController(vc, animated: true)
        } else {
            let navController = UINavigationController(rootViewController: vc)
            if #available(iOS 13.0, *) {
                navController.modalPresentationStyle = .fullScreen
            }
            presentingViewController.present(navController, animated: true)
        }
        self.isInNavController = true
    }

    internal func fetchDayLogFor(fromDate: Date,
                                 toDate: Date,
                                 completion: @escaping ([DayLog]) -> Void) {
        var dayLogs = [DayLog]()
        for time in stride(from: fromDate.timeIntervalSince1970, through: toDate.timeIntervalSince1970, by: 86400) {
            let currentDate = Date(timeIntervalSince1970: time)
            fetchDayRecords(date: currentDate) { (foodRecords) in
                let daylog = DayLog(date: currentDate, records: foodRecords)
                dayLogs.append(daylog)
                if time > toDate.timeIntervalSince1970 - 86400 {// last element
                    completion(dayLogs)
                }
            }
        }
    }

    deinit {
        print("deinit PassioInternalConnector")
    }

}

extension PassioInternalConnector: PassioConnector {

    public func updateUserProfile(userProfile: UserProfileModel) {
        guard let connector = passioExternalConnector else {
            return
        }
        connector.updateUserProfile(userProfile: userProfile)
    }

    public func fetchUserProfile(completion: @escaping (UserProfileModel?) -> Void) {
        guard let connector = passioExternalConnector else {
            completion(UserProfileModel())
            return
        }
        connector.fetchUserProfile { (userProfile) in
            completion(userProfile)
        }
    }

    public func updateRecord(foodRecord: FoodRecord, isNew: Bool) {
        guard let connector = passioExternalConnector else { return }
        var updatedFoodRecord = foodRecord
        if isNew, let dateForLogging = dateForLogging {
            updatedFoodRecord.createdAt = dateForLogging
            if let mealLabel = mealLabel {
                updatedFoodRecord.mealLabel = mealLabel
            }
        }
        connector.updateRecord(foodRecord: updatedFoodRecord, isNew: isNew)
    }

    public func deleteRecord(foodRecord: FoodRecord) {
        guard let connector = passioExternalConnector else { return }
        connector.deleteRecord(foodRecord: foodRecord)
    }

    public func fetchDayRecords(date: Date, completion: @escaping ([FoodRecord]) -> Void) {
        guard let connector = passioExternalConnector else {
            completion([])
            return
        }
        connector.fetchDayRecords(date: date) { (foodRecords) in
            completion(foodRecords)
        }
    }

    public func updateFavorite(foodRecord: FoodRecord) {
        guard let connector = passioExternalConnector else { return }
        connector.updateFavorite(foodRecord: foodRecord)
    }

    public func deleteFavorite(foodRecord: FoodRecord) {
        guard let connector = passioExternalConnector else { return }
        connector.deleteFavorite(foodRecord: foodRecord)
    }

    public func fetchFavorites(completion: @escaping ([FoodRecord]) -> Void) {
        guard let connector = passioExternalConnector else {
            completion([])
            return
        }
        connector.fetchFavorites { (favorites) in
            completion(favorites)
        }
    }

    public var bundleForModule: Bundle {
        guard let connector = passioExternalConnector else {
            return Bundle.main
        }
        return connector.bundleForModule
    }

    public var offsetFoodEditor: CGFloat {
        guard let connector = passioExternalConnector else { return 0}
        return connector.offsetFoodEditor
    }

}
