//
//  Date+Extension.swift
//  PassioPassport
//
//  Created by zvika on 4/3/19.
//  Copyright © 2023 Passiolife Inc. All rights reserved.
//

import Foundation

extension Date {

    static func atTime(hours: Int, minutes: Int) -> Date {
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
}
