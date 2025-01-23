import Foundation

public struct InsulinSensitivities: Codable {
    let units: GlucoseUnits
    let userPreferredUnits: GlucoseUnits
    let sensitivities: [InsulinSensitivityEntry]
    
    func inMgDl() -> InsulinSensitivities {
        switch (units) {
        case .mgdL:
            return self;
        case .mmolL:
            let sensitivities = self.sensitivities.map { InsulinSensitivityEntry(sensitivity: $0.sensitivity * 18, offset: $0.offset, start: $0.start) }
            return InsulinSensitivities(units: .mgdL, userPreferredUnits: self.userPreferredUnits, sensitivities: sensitivities)
        }
    }
}

extension InsulinSensitivities {
    private enum CodingKeys: String, CodingKey {
        case units
        case userPreferredUnits = "user_preferred_units"
        case sensitivities
    }
}

public struct InsulinSensitivityEntry: Codable {
    let sensitivity: Double
    let offset: Int
    let start: String
}

extension InsulinSensitivityEntry {
    private enum CodingKeys: String, CodingKey {
        case sensitivity
        case offset
        case start
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let sensitivity = try container.decode(Double.self, forKey: .sensitivity)
        let start = try container.decode(String.self, forKey: .start)
        let offset = try container.decode(Int.self, forKey: .offset)

        self = InsulinSensitivityEntry(sensitivity: sensitivity, offset: offset, start: start)
    }
}
