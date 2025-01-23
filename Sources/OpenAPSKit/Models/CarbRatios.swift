import Foundation

public struct CarbRatios: Codable {
    let units: CarbUnit
    let schedule: [CarbRatioEntry]
}

public struct CarbRatioEntry: Codable {
    let start: String
    let offset: Int
    let ratio: Double
}

enum CarbUnit: String, Codable {
    case grams
    case exchanges
}

extension CarbRatioEntry {
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

        self = CarbRatioEntry(start: start, offset: offset, ratio: ratio)
    }
}
