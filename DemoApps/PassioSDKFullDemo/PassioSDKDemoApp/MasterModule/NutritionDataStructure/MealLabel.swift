//
//  API.swift
//  PassioNutritionData
//
//  Created by Former Developer on 5/22/18.
//  Copyright © 2023 Passiolife Inc. All rights reserved.
//

import Foundation
#if canImport(PassioNutritionAISDK)
import PassioNutritionAISDK
#endif

public enum MealLabel: String, Comparable, Codable {

    case breakfast = "Breakfast",
    lunch = "Lunch",
    dinner = "Dinner",
    snack = "Snack"

    public init(rawValue: String) {
        switch rawValue {
        case "Breakfast": self = .breakfast
        case "Lunch": self = .lunch
        case "Dinner": self = .dinner
        default: self = .snack
        }
    }

    private var sortOrder: Int {
        switch self {
        case .breakfast:
            return 0
        case .lunch:
            return 1
        case .dinner:
            return 2
        case .snack:
            return 3
        }
    }

    public static let allValues = [breakfast, lunch, dinner, snack]

    public static func == (lhs: MealLabel, rhs: MealLabel) -> Bool {
        lhs.sortOrder == rhs.sortOrder
    }

    public static func < (lhs: MealLabel, rhs: MealLabel) -> Bool {
        lhs.sortOrder < rhs.sortOrder
    }

    public static func > (lhs: MealLabel, rhs: MealLabel) -> Bool {
        lhs.sortOrder > rhs.sortOrder
    }

    public static func <= (lhs: MealLabel, rhs: MealLabel) -> Bool {
        lhs.sortOrder <= rhs.sortOrder
    }

    public static func >= (lhs: MealLabel, rhs: MealLabel) -> Bool {
        lhs.sortOrder >= rhs.sortOrder
    }

    public static func fromDialogFlow(meal: String) -> MealLabel {
        switch meal {
        case "Breakfast":
            return .breakfast
        case "Lunch":
            return .lunch
        case "Dinner":
            return .dinner
        case "Snack":
            return .snack
        default:
            return MealLabel.mealLabelBy(time: Date())
        }
    }

    static func mealLabelBy(time: Date = Date()) -> MealLabel {

            struct TimeRange {
                var start: Date
                var end: Date
                func intersects( timestamp: Date) -> Bool {
                    return start < timestamp && timestamp <= end
                }
            }

            func getDateFor(hours: Int, minutes: Int) -> Date {
                guard let calendar = NSCalendar(calendarIdentifier: NSCalendar.Identifier.gregorian) else {
                    return Date()
                }
                // get the month/day/year componentsfor today's date.
                var dateComponents = calendar.components(
                    [NSCalendar.Unit.year,
                     NSCalendar.Unit.month,
                     NSCalendar.Unit.day],
                    from: Date())
                // Create an NSDate for the specified time today.
                dateComponents.hour = hours
                dateComponents.minute = minutes
                dateComponents.second = 0

                guard let newDate = calendar.date(from: dateComponents) else { return Date()
                }
                return newDate
            }

            let breakfast = TimeRange(start: getDateFor(hours: 4, minutes: 00),
                                      end: getDateFor(hours: 10, minutes: 30))
            let lunch = TimeRange(start: getDateFor(hours: 11, minutes: 30),
                                  end: getDateFor(hours: 14, minutes: 00))
            let dinner = TimeRange(start: getDateFor(hours: 17, minutes: 00),
                                   end: getDateFor(hours: 21, minutes: 00))

            if breakfast.intersects(timestamp: time) { return .breakfast }
            if lunch.intersects(timestamp: time) { return .lunch }
            if dinner.intersects(timestamp: time) { return .dinner }
            return .snack
        }

}
