//
//  isf.swift
//  OpenAPSKit
//
//  Created by Sam King on 1/23/25.
//

import Foundation

// I removed the cache that the Javascript version has to help keep it simple
struct Isf {
    static func isfLookup(isfData: InsulinSensitivities, timestamp: Date? = nil) throws -> Double? {
        
        let now = timestamp ?? Date()
                
        // Sort sensitivities by offset
        let sortedSensitivities = isfData.sensitivities.sorted { $0.offset < $1.offset }
        
        // Verify first offset is 0
        guard let firstSensitivity = sortedSensitivities.first,
              firstSensitivity.offset == 0 else {
            return -1
        }
        
        // Default to last entry
        guard var isfSchedule = sortedSensitivities.last else {
            return -1
        }
        
        // Find matching sensitivity for current time
        for (curr, next) in zip(sortedSensitivities, sortedSensitivities.dropFirst()) {
            if try now.isMinutesFromMidnightWithinRange(lowerBound: curr.offset, upperBound: next.offset) {
                isfSchedule = curr
                break
            }
        }
        
        return isfSchedule.sensitivity
    }
}
