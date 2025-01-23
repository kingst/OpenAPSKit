import Foundation

public struct PumpSettings: Codable {
    let insulinActionCurve: Double
    let maxBolus: Double
    let maxBasal: Double
}

extension PumpSettings {
    private enum CodingKeys: String, CodingKey {
        case insulinActionCurve = "insulin_action_curve"
        case maxBolus
        case maxBasal
    }
}
