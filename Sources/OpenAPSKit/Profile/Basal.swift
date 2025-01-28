//
//  Basal.swift
//  OpenAPSKit
//
//  Created by Sam King on 1/23/25.
//

import Foundation

struct Basal {
    static func basalLookup(_ basalProfile: [BasalProfileEntry], now: Date? = nil) throws -> Double? {
        let nowDate = now ?? Date()
        
        // Original had a sort but it was a no-op if 'i' wasn't present, so we can skip it
        let basalProfileData = basalProfile
        
        guard let lastBasalRate = basalProfileData.last?.rate, lastBasalRate != 0 else {
            print("ERROR: bad basal schedule \(basalProfile)")
            return nil
        }
        
        // Look for matching time slot
        for (curr, next) in zip(basalProfileData, basalProfileData.dropFirst()) {
            if try nowDate.isMinutesFromMidnightWithinRange(lowerBound: curr.minutes, upperBound: next.minutes) {
                
                return Double(round(curr.rate * 1000)) / 1000
            }
        }
        
        // If no matching slot found, return last basal rate
        return Double(round(lastBasalRate * 1000)) / 1000
    }
    
    static func maxDailyBasal(_ basalProfile: [BasalProfileEntry]) -> Double? {
        guard let maxBasal = basalProfile.map({ $0.rate }).max() else {
            return nil
        }
        
        // In Javascript Number is floating point, so we don't need to do
        // the * 1000 / 1000
        return maxBasal
    }
}
