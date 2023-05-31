//
//  PassioExternalConnector.swift
//
//  Created by zvika on 1/21/20.
//  Copyright © 2023 Passio Inc. All rights reserved.
//

import Foundation
import UIKit
import PassioNutritionAISDK

#if canImport(PassioAppModule)
import PassioAppModule
#endif

public typealias PassioID = String

class PassioExternalConnector {

    // MARK: Shared Object
    public class var shared: PassioExternalConnector {
        if Static.instance == nil {
            Static.instance = PassioExternalConnector()
        }
        return Static.instance!
    }
    public func shutDown() {
        Static.instance = nil
    }
    private struct Static {
        fileprivate static var instance: PassioExternalConnector?
    }
    private init() {}

    // MARK: Internal implementation for QA
    private let fileManager = FileManager.default

    private func updateRecored(record: FoodRecord, url: URL) -> Bool {
        do {
            let encodedData = try? JSONEncoder().encode(record)
            if fileManager.fileExists(atPath: url.path ) {
                try fileManager.removeItem(at: url)
            }
            do {
                try encodedData?.write(to: url)
                return true
            } catch {
                return false
            }
        } catch {
            return false
        }
    }

    private func deleteRecord(record: FoodRecord, url: URL) -> Bool {
        if fileManager.fileExists(atPath: url.path) {
            do {
                try fileManager.removeItem(at: url)
                return true
            } catch {
                print("No record was found")
                return false
            }
        }
        return false
    }

    private func getRecordsFor(url: URL) -> [FoodRecord] {
        var foodRecords = [FoodRecord]()
        do {
            let directoryContents = try fileManager.contentsOfDirectory(at: url, includingPropertiesForKeys: nil)
            for fileURL in directoryContents {
                if let data = try? Data(contentsOf: fileURL) {
                    let decoder = JSONDecoder()
                    let foodRecord = try decoder.decode(FoodRecord.self, from: data)
                    foodRecords.append(foodRecord)
                }
            }
            return foodRecords
        } catch {
            return foodRecords
        }
    }

    private func urlForSaving(record: FoodRecord) -> URL? {
        let date = record.createdAt
        guard let urlForFile = urlForSavingFiles(date: date) else {
            return nil
        }
        let finalURL = urlForFile.appendingPathComponent(record.uuid.replacingOccurrences(of: "-", with: "") + ".json")
        return finalURL
    }

    private func urlForSavingFiles(date: Date) -> URL? {
        guard let appSupportDir = try? fileManager.url(for: .applicationSupportDirectory,
                                                       in: .userDomainMask,
                                                       appropriateFor: nil,
                                                       create: true) else {
            return nil
        }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd"
        let directory = dateFormatter.string(from: date)
        let dirURL = appSupportDir.appendingPathComponent("date" + directory, isDirectory: true)
        do {
            try fileManager.createDirectory(atPath: dirURL.path, withIntermediateDirectories: true, attributes: nil)
        } catch {
            print("can't create directory at \(dirURL)")
        }
        return dirURL
    }

    private var urlForFavoritesDirectory: URL? {
        guard let appSupportDir = try? fileManager.url(for: .applicationSupportDirectory,
                                                       in: .userDomainMask,
                                                       appropriateFor: nil,
                                                       create: true) else {
            return nil
        }
        let dirURL = appSupportDir.appendingPathComponent("passiofavorites", isDirectory: true)
        do {
            try fileManager.createDirectory(atPath: dirURL.path, withIntermediateDirectories: true, attributes: nil)
        } catch {
            print("can't create directory at \(dirURL)")
        }
        return dirURL
    }

    private func urlForSaving(favorite: FoodRecord) -> URL? {
        guard let dirURL = urlForFavoritesDirectory else {
            return nil}
        let finalURL = dirURL.appendingPathComponent(favorite.uuid.replacingOccurrences(of: "-", with: "") + ".json")
        return finalURL
    }

    // photos
    private func urlForSavingPhoto(uuid: String) -> URL? {
        guard let appSupportDir = try? fileManager.url(for: .applicationSupportDirectory,
                                                       in: .userDomainMask,
                                                       appropriateFor: nil,
                                                       create: true) else {
            return nil
        }
        let dirURL = appSupportDir.appendingPathComponent("passioImages", isDirectory: true)
        do {
            try fileManager.createDirectory(atPath: dirURL.path, withIntermediateDirectories: true, attributes: nil)
        } catch {
            print("can't create directory at \(dirURL)")
        }
        let finalURL = dirURL.appendingPathComponent(uuid.replacingOccurrences(of: "-", with: "") + ".jpg")
        return finalURL
    }

    private var urlForUserProfileModel: URL? {
        guard let appSupportDir = try? fileManager.url(for: .applicationSupportDirectory,
                                                       in: .userDomainMask,
                                                       appropriateFor: nil,
                                                       create: true) else {
            return nil
        }
        let dirURL = appSupportDir.appendingPathComponent("userProfile")// appendingPathComponent("userProfileModel.json")
        do {
            try fileManager.createDirectory(atPath: dirURL.path, withIntermediateDirectories: true, attributes: nil)
        } catch {
            print("can't create directory at \(dirURL)")
        }
        return dirURL.appendingPathComponent("userProfileModel.json")
    }

    private func saveUserProfileModel(userProfileModel: UserProfileModel) {
        guard let dirURL = urlForUserProfileModel else { return }
        do {
            let encodedData = try? JSONEncoder().encode(userProfileModel)
            //  print("url.path   ", url.path)
            if fileManager.fileExists(atPath: dirURL.path ) {
                try fileManager.removeItem(at: dirURL)
            }
            do {
                try encodedData?.write(to: dirURL)
                return
            } catch {
                return
            }
        } catch {
            return
        }
    }

    private func getUserProfileModel() -> UserProfileModel {
        let userProfile = UserProfileModel()
        guard let dirURL = urlForUserProfileModel else { return userProfile }
        do {
            let decoder = JSONDecoder()
            if let data = try? Data(contentsOf: dirURL),
               let profile = try? decoder.decode(UserProfileModel.self, from: data) {
                return profile
            }
        }
        return userProfile
    }
    deinit {
        print("deinit PassioExternalConnector")
    }

}

// MARK: PassioConnector
extension PassioExternalConnector: PassioConnector {

    func fetchUserProfile(completion: @escaping (UserProfileModel?) -> Void) {

    }

    func updateUserProfile(userProfile: UserProfileModel) {

    }

    func fetchDayRecords(date: Date, completion: @escaping ([FoodRecord]) -> Void) {
        if let urlForDate = urlForSavingFiles(date: date) {
            let records = getRecordsFor(url: urlForDate)
            completion(records)
        } else {
            completion([])
        }

    }

    func fetchFavorites(completion: @escaping ([FoodRecord]) -> Void) {

        if let url = urlForFavoritesDirectory {
            let favorites = getRecordsFor(url: url)
            completion(favorites)
        } else {
            completion([])
        }
    }

    var userProfileModel: UserProfileModel {
        get {
            getUserProfileModel()
        }
        set {
            saveUserProfileModel(userProfileModel: newValue)
        }
    }

    var offsetFoodEditor: CGFloat {
        0
    }

    var bundleForModule: Bundle {
        Bundle(for: PassioInternalConnector.self)
    }

    // MARK: Working with Food Records
    public func updateRecord(foodRecord: FoodRecord, isNew: Bool) {
        guard let url = urlForSaving(record: foodRecord) else {
            return
        }
        _ = updateRecored(record: foodRecord, url: url)
    }

    public func deleteRecord(foodRecord: FoodRecord) {
        guard let url = urlForSaving(record: foodRecord) else { return  }
        _ = deleteRecord(record: foodRecord, url: url)
    }

    public func getRecordsForDate(date: Date) -> [FoodRecord] {
        guard let urlForDate = urlForSavingFiles(date: date) else { return [] }
        let records = getRecordsFor(url: urlForDate)
        return records
    }

    // MARK: Working with Favorites

    public func updateFavorite(foodRecord: FoodRecord) {
        guard let url = urlForSaving(favorite: foodRecord) else { return  }
        _ = updateRecored(record: foodRecord, url: url)
    }

    public func deleteFavorite(foodRecord: FoodRecord) {
        guard let url = urlForSaving(favorite: foodRecord) else { return }
        _ = deleteRecord(record: foodRecord, url: url)
    }

    public func getFavorites() -> [FoodRecord] {
        guard let url = urlForFavoritesDirectory else { return [] }
        return getRecordsFor(url: url)
    }

    // MARK: Working with Photos

    //    public func savePhoto(image: UIImage, uuid: String)  {
    //        return false
    //        guard let url = urlForSavingPhoto(uuid: uuid) else { return false }
    //        if let data = image.jpegData(compressionQuality: 0.5) {
    //            do {
    //                if fileManager.fileExists(atPath: url.path) {
    //                    try? fileManager.removeItem(at: url.path)
    //                }
    //                try data.write(to: url )
    //                //                print("Photo saved 123")
    //                return true
    //            } catch {
    //                print("error saving Photo:", error)
    //                return false
    //            }
    //        }
    //        return false
    //    }
    //
    //    public func getPhotoFor(uuid: String) -> UIImage? {
    //        guard let url = urlForSavingPhoto(uuid: uuid) else { return nil }
    //        let path = url.path
    //        if fileManager.fileExists(atPath: path) {
    //            return UIImage(contentsOfFile: path)
    //        } else {
    //            return nil
    //        }
    //    }

}
