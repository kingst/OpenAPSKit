//
//  ProfileIsfTests.swift
//  OpenAPSKit
//
//  Created by Sam King on 1/26/25.
//

@testable import OpenAPSKit
import Testing
import Foundation

@Suite("ISF Profile")
struct ISFTests {
    let standardISF = InsulinSensitivities(
        units: .mgdL,
        userPreferredUnits: .mgdL,
        sensitivities: [
            InsulinSensitivityEntry(sensitivity: 100, offset: 0, start: "00:00:00"),
            InsulinSensitivityEntry(sensitivity: 80, offset: 180, start: "03:00:00"),
            InsulinSensitivityEntry(sensitivity: 90, offset: 360, start: "06:00:00")
        ]
    )
    
    @Test("should return current insulin sensitivity factor from schedule")
    func currentISF() async throws {
        let now = Calendar.current.date(from: DateComponents(year: 2025, month: 1, day: 26, hour: 2))!
        let sensitivity = try Isf.isfLookup(isfData: standardISF, timestamp: now)
        #expect(sensitivity == 100)
    }
    
    @Test("should handle sensitivity schedule changes")
    func handleScheduleChanges() async throws {
        let now = Calendar.current.date(from: DateComponents(year: 2025, month: 1, day: 26, hour: 4))!
        let sensitivity = try Isf.isfLookup(isfData: standardISF, timestamp: now)
        #expect(sensitivity == 80)
    }
    
    @Test("should use last sensitivity if past schedule end")
    func useLastSensitivity() async throws {
        let now = Calendar.current.date(from: DateComponents(year: 2025, month: 1, day: 26, hour: 23))!
        let sensitivity = try Isf.isfLookup(isfData: standardISF, timestamp: now)
        #expect(sensitivity == 90)
    }
    
    @Test("should produce the same result without a cache")
    func cacheLastResult() async throws {
        let now = Calendar.current.date(from: DateComponents(year: 2025, month: 1, day: 26, hour: 4, minute: 30))!
        let sensitivity1 = try Isf.isfLookup(isfData: standardISF, timestamp: now)
        let sensitivity2 = try Isf.isfLookup(isfData: standardISF, timestamp: now)
        #expect(sensitivity1 == sensitivity2)
        #expect(sensitivity1 == 80)
    }
    
    @Test("should return -1 for invalid profile with non-zero first offset")
    func handleInvalidProfile() async throws {
        let invalidISF = InsulinSensitivities(
            units: .mgdL,
            userPreferredUnits: .mgdL,
            sensitivities: [
                InsulinSensitivityEntry(sensitivity: 100, offset: 30, start: "00:30:00")
            ]
        )
        let sensitivity = try Isf.isfLookup(isfData: invalidISF)
        #expect(sensitivity == -1)
    }
}
