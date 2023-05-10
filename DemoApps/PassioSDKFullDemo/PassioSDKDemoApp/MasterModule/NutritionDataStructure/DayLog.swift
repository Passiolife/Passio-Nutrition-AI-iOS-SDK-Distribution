//
//  DayLog.swift
//  PassioNutritionData
//
//  Created by James Kelly on 29/08/2018.
//  Copyright © 2023 Passiolife Inc. All rights reserved.
//

import Foundation

#if canImport(PassioNutritionAISDK)
import PassioNutritionAISDK
#endif

public class DayLog {

    private(set) var date: Date
    private(set) var records: [FoodRecord]

    init(date: Date) {
        self.date = date
        records = []
    }

    init(date: Date, records: [FoodRecord]) {
        self.date = date
        self.records = records
    }

    func merge(_ other: DayLog) {
        var map: [String: FoodRecord] = [:]
        for record in other.records {
            map[record.uuid] = record
        }
        for localRecord in records {
            if let remoteRecord = map[localRecord.uuid] {
                // Pick the most recent one
                if localRecord.createdAt > remoteRecord.createdAt {
                    map[localRecord.uuid] = localRecord
                }
            } else {
                map[localRecord.uuid] = localRecord
            }
        }
        self.records = map.compactMap { $1 }
    }

    func add(record: FoodRecord) {
        records.append(record)
    }

    func delete(record: FoodRecord) {
        records = records.filter { $0.uuid != record.uuid }
    }

    func delete(uuid: String) {
        records = records.filter { $0.uuid != uuid }
    }

    func update(record: FoodRecord) {
        for (index, storedRecord) in records.enumerated() where storedRecord.uuid == record.uuid {
                records[index] = record
                return
        }
    }

    func getFoodRecordsByMeal(mealLabel: MealLabel?) -> [FoodRecord] {
        guard let mealLabel = mealLabel else {
            return records.sorted {$0.createdAt > $1.createdAt}
        }
        return records.filter {$0.mealLabel == mealLabel}.sorted {$0.createdAt > $1.createdAt}
    }

    var dailyCarbs: Double {
        records.map {$0.totalCarbs}.reduce(0.0, +).roundDigits(afterDecimal: 1)
    }

    var dailyProtein: Double {
        records.map {$0.totalProteins}.reduce(0.0, +).roundDigits(afterDecimal: 1)
    }

    var dailyFat: Double {
        records.map {$0.totalFat}.reduce(0.0, +).roundDigits(afterDecimal: 1)
    }

    var dailyCalories: Double {
        records.map {$0.totalCalories}.reduce(0.0, +).roundDigits(afterDecimal: 0)
    }

}
