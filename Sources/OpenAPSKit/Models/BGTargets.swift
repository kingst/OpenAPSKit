import Foundation

public struct BGTargets: Codable {
    let units: GlucoseUnits
    let userPreferredUnits: GlucoseUnits
    var targets: [BGTargetEntry]
}

extension BGTargets {
    private enum CodingKeys: String, CodingKey {
        case units
        case userPreferredUnits = "user_preferred_units"
        case targets
    }
}

struct BGTargetEntry: Codable {
    var low: Double
    var high: Double
    var start: String
    var offset: Int
}
