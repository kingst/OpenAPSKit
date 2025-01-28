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
    var endOffset: Int?
    let id: UUID // we use this to help with mutating inputs, we don't serialize it
    
    public init(sensitivity: Double, offset: Int, start: String, endOffset: Int? = nil, id: UUID? = nil) {
        self.sensitivity = sensitivity
        self.offset = offset
        self.start = start
        self.endOffset = endOffset
        self.id = id ?? UUID()
    }
    
    enum CodingKeys: CodingKey {
        case sensitivity
        case offset
        case start
        case endOffset
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(sensitivity, forKey: .sensitivity)
        try container.encode(offset, forKey: .offset)
        try container.encode(start, forKey: .start)
        try container.encodeIfPresent(endOffset, forKey: .endOffset)
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        sensitivity = try container.decode(Double.self, forKey: .sensitivity)
        offset = try container.decode(Int.self, forKey: .offset)
        start = try container.decode(String.self, forKey: .start)
        endOffset = try container.decodeIfPresent(Int.self, forKey: .endOffset)
        id = UUID()
    }
}
