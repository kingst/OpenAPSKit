import Foundation

public struct OKPumpSettings: Codable {
    let insulinActionCurve: Double
    let maxBolus: Double
    let maxBasal: Double
}

extension OKPumpSettings {
    private enum CodingKeys: String, CodingKey {
        case insulinActionCurve = "insulin_action_curve"
        case maxBolus
        case maxBasal
    }
}
