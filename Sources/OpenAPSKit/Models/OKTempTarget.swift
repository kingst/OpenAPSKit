import Foundation

public struct OKTempTarget: Codable, Identifiable, Equatable, Hashable {
    public var id = UUID().uuidString
    let name: String?
    var createdAt: Date
    let targetTop: Double?
    let targetBottom: Double?
    let duration: Double
    let enteredBy: String?
    let reason: String?

    static let manual = "Trio"
    static let custom = "Temp target"
    static let cancel = "Cancel"

    var displayName: String {
        name ?? reason ?? OKTempTarget.custom
    }

    public static func == (lhs: OKTempTarget, rhs: OKTempTarget) -> Bool {
        lhs.createdAt == rhs.createdAt
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(createdAt)
    }

    static func cancel(at date: Date) -> OKTempTarget {
        OKTempTarget(
            name: OKTempTarget.cancel,
            createdAt: date,
            targetTop: 0,
            targetBottom: 0,
            duration: 0,
            enteredBy: OKTempTarget.manual,
            reason: OKTempTarget.cancel
        )
    }
}

extension OKTempTarget {
    private enum CodingKeys: String, CodingKey {
        case id = "_id"
        case name
        case createdAt = "created_at"
        case targetTop
        case targetBottom
        case duration
        case enteredBy
        case reason
    }
}
