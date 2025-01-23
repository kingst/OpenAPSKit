//
//  MedtronicClock.swift
//  OpenAPSKit
//
//  Created by Sam King on 1/23/25.
//

import Foundation

struct MedtronicClock {
    static func getTime(minutes: Int) -> Date {
        let calendar = Calendar.current
        let today = Date()
        var components = calendar.dateComponents([.year, .month, .day], from: today)
        components.hour = 0
        components.minute = minutes
        components.second = 0
        
        return calendar.date(from: components) ?? today
    }
}
