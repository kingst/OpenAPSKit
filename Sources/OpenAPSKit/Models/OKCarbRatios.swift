import Foundation

public struct OKCarbRatios: Codable {
    let units: OKCarbUnit
    var schedule: [OKCarbRatioEntry]
}

public struct OKCarbRatioEntry: Codable {
    let start: String
    let offset: Int
    var ratio: Double
}

enum OKCarbUnit: String, Codable {
    case grams
    case exchanges
}

extension OKCarbRatioEntry {
    private enum CodingKeys: String, CodingKey {
        case start
        case offset
        case ratio
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let start = try container.decode(String.self, forKey: .start)
        let offset = try container.decode(Int.self, forKey: .offset)
        let ratio = try container.decode(Double.self, forKey: .ratio)

        self = OKCarbRatioEntry(start: start, offset: offset, ratio: ratio)
    }
}
