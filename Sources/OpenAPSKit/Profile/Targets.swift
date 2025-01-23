//
//  Targets.swift
//  OpenAPSKit
//
//  Created by Sam King on 1/23/25.
//

import Foundation

struct Targets {
    static func lookup(targets: BGTargets, tempTargets: [TempTarget], profile: Profile) throws -> (ComputedBGTargets, Int) {
        let now = Date()
        
        // Find current target
        var bgComputedTargets = targets.targets.map { ComputedBGTargetEntry(low: $0.low, high: $0.high, start: $0.start, offset: $0.offset) }
        
        guard bgComputedTargets.count > 0 else {
            throw ProfileError.invalidBgTargets
        }
        
        var targetIdx = bgComputedTargets.count - 1
        for (idx, (curr, next)) in zip(bgComputedTargets, bgComputedTargets.dropFirst()).enumerated() {
            if now >= MedtronicClock.getTime(minutes: curr.offset) &&
               now < MedtronicClock.getTime(minutes: next.offset) {
                targetIdx = idx
                break
            }
        }
        
        // Apply profile target if specified
        if let targetBg = profile.targetBg {
            bgComputedTargets[targetIdx].low = targetBg
        }
        bgComputedTargets[targetIdx].high = bgComputedTargets[targetIdx].low
        
        // Handle temp targets
        let sortedTempTargets = tempTargets.sorted { $0.createdAt > $1.createdAt }
        
        for target in sortedTempTargets {
            let start = target.createdAt
            let expires = start.addingTimeInterval(target.duration * 60)
            
            if now >= start && target.duration == 0 {
                // Cancel temp targets
                break
            } else if let targetBottom = target.targetBottom,
                      let targetTop = target.targetTop {
                if now >= start && now < expires {
                    bgComputedTargets[targetIdx].high = targetTop
                    bgComputedTargets[targetIdx].low = targetBottom
                    bgComputedTargets[targetIdx].temptargetSet = true
                    break
                }
            } else {
                print("eventualBG target range invalid: \(target.targetBottom ?? -1)-\(target.targetTop ?? -1)")
                break
            }
        }
        
        return (ComputedBGTargets(units: targets.units, userPreferredUnits: targets.userPreferredUnits, targets: bgComputedTargets), targetIdx)
    }

    static func boundTargetRange(_ entry: ComputedBGTargetEntry) -> ComputedBGTargetEntry {
        var target = entry
        // Convert from mmol/L to mg/dL if needed
        if target.high < 20 { target.high *= 18 }
        if target.low < 20 { target.low *= 18 }
        
        // hard-code lower bounds for min_bg and max_bg in case pump is set too low, or units are wrong
        var maxBg = max(80, target.high);
        var minBg = max(80, target.low);
        // hard-code upper bound for min_bg in case pump is set too high
        minBg = min(200, minBg);
        maxBg = min(200, maxBg);
        
        target.minBg = minBg
        target.maxBg = maxBg
        
        return target
    }
    static func bgTargetsLookup(targets: BGTargets, tempTargets: [TempTarget], profile: Profile) throws -> (ComputedBGTargets, ComputedBGTargetEntry) {
        var (computedBgTargets, targetIdx) = try lookup(targets: targets, tempTargets: tempTargets, profile: profile)
        let currentTarget = boundTargetRange(computedBgTargets.targets[targetIdx])
        computedBgTargets.targets[targetIdx] = currentTarget
        return (computedBgTargets, currentTarget)
    }
}
