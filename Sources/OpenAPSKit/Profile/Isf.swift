//
//  isf.swift
//  OpenAPSKit
//
//  Created by Sam King on 1/23/25.
//

import Foundation

struct Isf {
    static func isfLookup(isfData: InsulinSensitivities, timestamp: Date? = nil) -> Double? {
        // Static cache for last result
        struct Cache {
            static var lastResult: (sensitivity: Double, offset: Int, endOffset: Int)?
        }
        
        let now = timestamp ?? Date()
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: now)
        let nowMinutes = (components.hour ?? 0) * 60 + (components.minute ?? 0)
        
        // Check cache
        if let lastResult = Cache.lastResult,
           nowMinutes >= lastResult.offset && nowMinutes < lastResult.endOffset {
            return lastResult.sensitivity
        }
        
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
        var endMinutes = 1440  // 24 hours in minutes
        
        // Find matching sensitivity for current time
        for i in 0..<(sortedSensitivities.count - 1) {
            let currentISF = sortedSensitivities[i]
            let nextISF = sortedSensitivities[i + 1]
            
            if nowMinutes >= currentISF.offset && nowMinutes < nextISF.offset {
                endMinutes = nextISF.offset
                isfSchedule = currentISF
                break
            }
        }
        
        // Update cache
        Cache.lastResult = (
            sensitivity: isfSchedule.sensitivity,
            offset: isfSchedule.offset,
            endOffset: endMinutes
        )
        
        return isfSchedule.sensitivity
    }
}
