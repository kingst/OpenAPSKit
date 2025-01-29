import Foundation

public struct OKAutotune: Codable {
    var createdAt: Date?
    let basalProfile: [OKBasalProfileEntry]?
    let isfProfile: OKInsulinSensitivities?
    let sensitivity: Double
    let carbRatio: Double?
}

extension OKAutotune {
    private enum CodingKeys: String, CodingKey {
        case createdAt = "created_at"
        case basalProfile = "basalprofile"
        case sensitivity = "sens"
        case carbRatio = "carb_ratio"
        case isfProfile
    }
}
