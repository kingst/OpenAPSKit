import Foundation

public struct BGTargets: Codable {
    let units: GlucoseUnits
    let userPreferredUnits: GlucoseUnits
    var targets: [BGTargetEntry]
    
    func inMgDl() -> BGTargets {
        switch (units) {
        case .mgdL:
            return self
        case .mmolL:
            let targets = targets.map { BGTargetEntry(low: $0.low * 18, high: $0.high * 18, start: $0.start, offset: $0.offset)}
            return BGTargets(units: .mgdL, userPreferredUnits: self.userPreferredUnits, targets: targets)
        }
    }
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
