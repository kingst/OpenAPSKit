import Foundation

public struct OKBasalProfileEntry: Codable, Equatable {
    let start: String
    let minutes: Int
    let rate: Double
}

extension OKBasalProfileEntry {
    private enum CodingKeys: String, CodingKey {
        case start
        case minutes
        case rate
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let start = try container.decode(String.self, forKey: .start)
        let minutes = try container.decode(Int.self, forKey: .minutes)
        let rate = try container.decode(Double.self, forKey: .rate)

        self = OKBasalProfileEntry(start: start, minutes: minutes, rate: rate)
    }
}
