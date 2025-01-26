//
//  Carbs.swift
//  OpenAPSKit
//
//  Created by Sam King on 1/23/25.
//

import Foundation

struct Carbs {
    static func carbRatioLookup(carbRatio: CarbRatios, now: Date = Date()) -> Double? {
       
       // Get last schedule as default
       guard let lastSchedule = carbRatio.schedule.last else { return nil }
       var currentRatio = lastSchedule.ratio
       
       // Find matching schedule for current time
       for i in 0..<(carbRatio.schedule.count - 1) {
           if now >= MedtronicClock.getTime(minutes: carbRatio.schedule[i].offset) &&
                now < MedtronicClock.getTime(minutes: carbRatio.schedule[i + 1].offset) {
               currentRatio = carbRatio.schedule[i].ratio
               
               // Check for invalid values
               if currentRatio < 3 || currentRatio > 150 {
                   print("Error: carbRatio of \(currentRatio) out of bounds.")
                   return nil
               }
               break
           }
       }
       
       // Convert exchanges to grams
        switch (carbRatio.units) {
        case .exchanges:
            return 12 / currentRatio
        case .grams:
            return currentRatio
        }
    }
}
