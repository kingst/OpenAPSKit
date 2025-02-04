import Foundation

enum OKGlucoseUnits: String, Codable, Equatable {
    case mgdL = "mg/dL"
    case mmolL = "mmol/L"

    static let exchangeRate: Double = 0.0555
}
