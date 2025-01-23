import Foundation

public struct BloodGlucose: Codable, Identifiable, Hashable {
    enum Direction: String, Codable {
        case tripleUp = "TripleUp"
        case doubleUp = "DoubleUp"
        case singleUp = "SingleUp"
        case fortyFiveUp = "FortyFiveUp"
        case flat = "Flat"
        case fortyFiveDown = "FortyFiveDown"
        case singleDown = "SingleDown"
        case doubleDown = "DoubleDown"
        case tripleDown = "TripleDown"
        case none = "NONE"
        case notComputable = "NOT COMPUTABLE"
        case rateOutOfRange = "RATE OUT OF RANGE"
    }

    var _id = UUID().uuidString
    public var id: String {
        _id
    }

    var sgv: Int?
    var direction: Direction?
    let date: Decimal
    let dateString: Date
    let unfiltered: Decimal?
    let filtered: Decimal?
    let noise: Int?
    var glucose: Int?

    let type: String?

    var activationDate: Date? = nil
    var sessionStartDate: Date? = nil
    var transmitterID: String? = nil

    var isStateValid: Bool { sgv ?? 0 >= 39 && noise ?? 1 != 4 }

    public static func == (lhs: BloodGlucose, rhs: BloodGlucose) -> Bool {
        lhs.dateString == rhs.dateString
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(dateString)
    }
}

enum GlucoseUnits: String, Codable, Equatable {
    case mgdL = "mg/dL"
    case mmolL = "mmol/L"

    static let exchangeRate: Double = 0.0555
}

extension Int {
    var asMmolL: Double {
        return (Double(self) * GlucoseUnits.exchangeRate).rounded()
    }
}
