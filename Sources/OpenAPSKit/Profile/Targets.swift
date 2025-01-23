//
//  Targets.swift
//  OpenAPSKit
//
//  Created by Sam King on 1/23/25.
//

import Foundation

struct Targets {
    static func bgTargetsLookup(targets: BGTargets, tempTargets: [TempTarget], profile: Profile) -> (ComputedBGTargets, ComputedBGTargetEntry) {
        let now = Date()
        
        // Convert BGTargetEntry to ComputedBGTargetEntry, handling mmol/L conversion
        var computedTargets = targets.targets.map { target -> ComputedBGTargetEntry in
            var high = target.high
            var low = target.low
            
            if high < 20 { high *= 18 }
            if low < 20 { low *= 18 }
            
            return ComputedBGTargetEntry(
                low: low,
                high: high,
                start: target.start,
                offset: target.offset,
                maxBg: min(200, max(80, high)),
                minBg: min(200, max(80, low)),
                temptargetSet: nil
            )
        }
        
        // Get last target as default
        guard var currentTarget = computedTargets.last else {
            fatalError("No targets available")
        }
        
        // Find matching target for current time
        for i in 0..<(computedTargets.count - 1) {
            if now >= MedtronicClock.getTime(minutes: currentTarget.offset) &&
                now < MedtronicClock.getTime(minutes: computedTargets[i + 1].offset) {
                currentTarget = computedTargets[i]
                break
            }
        }
        
        // Apply profile target if specified
        if let profileTarget = profile.targetBg {
            currentTarget.low = profileTarget
            currentTarget.high = profileTarget
            currentTarget.maxBg = min(200, max(80, profileTarget))
            currentTarget.minBg = min(200, max(80, profileTarget))
        }
        
        // Apply temp targets
        let sortedTempTargets = tempTargets.sorted { $0.createdAt > $1.createdAt }
        
        for tempTarget in sortedTempTargets {
            let expires = tempTarget.createdAt.addingTimeInterval(tempTarget.duration * 60)
            
            if now >= tempTarget.createdAt && tempTarget.duration == 0 {
                // Cancel temp targets - keep currentTarget as is
                break
            } else if let targetBottom = tempTarget.targetBottom,
                        let targetTop = tempTarget.targetTop {
                if now >= tempTarget.createdAt && now < expires {
                    currentTarget.high = targetTop
                    currentTarget.low = targetBottom
                    currentTarget.maxBg = min(200, max(80, targetTop))
                    currentTarget.minBg = min(200, max(80, targetBottom))
                    currentTarget.temptargetSet = true
                    break
                }
            } else {
                print("eventualBG target range invalid: \(tempTarget.targetBottom ?? -1)-\(tempTarget.targetTop ?? -1)")
                break
            }
        }
        
        let computedBGTargets = ComputedBGTargets(
            units: targets.units,
            userPreferredUnits: targets.userPreferredUnits,
            targets: computedTargets
        )
        
        return (computedBGTargets, currentTarget)
    }
}
