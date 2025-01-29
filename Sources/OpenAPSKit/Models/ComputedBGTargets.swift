//
//  ComputedBGTargets.swift
//  OpenAPSKit
//
//  Created by Sam King on 1/23/25.
//

public struct ComputedBGTargetEntry: Codable {
    var low: Double
    var high: Double
    var start: String
    var offset: Int
    var maxBg: Double?
    var minBg: Double?
    var temptargetSet: Bool?
}

extension ComputedBGTargetEntry {
    private enum CodingKeys: String, CodingKey {
        case low
        case high
        case start
        case offset
        case maxBg = "max_bg"
        case minBg = "min_bg"
        case temptargetSet = "temptarget_set"
    }
}

public struct ComputedBGTargets: Codable {
    let units: OKGlucoseUnits
    let userPreferredUnits: OKGlucoseUnits
    var targets: [ComputedBGTargetEntry]
}

extension ComputedBGTargets {
    private enum CodingKeys: String, CodingKey {
        case units
        case userPreferredUnits = "user_preferred_units"
        case targets
    }
}
