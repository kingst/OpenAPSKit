import Foundation

public struct OKBGTargets: Codable {
    let units: OKGlucoseUnits
    let userPreferredUnits: OKGlucoseUnits
    var targets: [OKBGTargetEntry]
    
    func inMgDl() -> OKBGTargets {
        switch (units) {
        case .mgdL:
            return self
        case .mmolL:
            let targets = targets.map { OKBGTargetEntry(low: $0.low * 18, high: $0.high * 18, start: $0.start, offset: $0.offset)}
            return OKBGTargets(units: .mgdL, userPreferredUnits: self.userPreferredUnits, targets: targets)
        }
    }
}

extension OKBGTargets {
    private enum CodingKeys: String, CodingKey {
        case units
        case userPreferredUnits = "user_preferred_units"
        case targets
    }
}

struct OKBGTargetEntry: Codable {
    var low: Double
    var high: Double
    var start: String
    var offset: Int
}
