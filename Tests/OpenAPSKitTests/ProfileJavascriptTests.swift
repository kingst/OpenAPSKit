//
//  ProfileJavascriptTests.swift
//  OpenAPSKit
//
//  Created by Sam King on 1/21/25.
//

import Testing
import Foundation
@testable import OpenAPSKit

/// Test data matching the JavaScript baseInputs structure
struct TestInputs {
    static let settings: [String: Any] = [
        "insulin_action_curve": Double(3)
    ]
    
    static let basals: [BasalProfile] = [
        BasalProfile(i: 0, minutes: 0, rate: 1, start: "00:00")
    ]
    
    static let targets = BGTargets(
        units: "mg/dL",
        user_preferred_units: "mg/dL",
        targets: [
            BGTargets.Target(
                high: 120,
                low: 100,
                min_bg: 100,
                max_bg: 120,
                start: "00:00",
                offset: 0
            )
        ]
    )
    
    static let isf = ISFProfile(
        sensitivities: [
            ISFProfile.Sensitivity(
                i: 0,
                sensitivity: 100,
                offset: 0,
                start: "00:00"
            )
        ]
    )
    
    static let carbRatio = CarbRatios(
        units: "grams",
        schedule: [
            CarbRatios.Schedule(
                ratio: 20,
                start: "00:00",
                offset: 0
            )
        ]
    )
}

@Suite("Profile Generator Tests")
struct ProfileJavascriptTests {
    
    @Test("Basic profile creation from inputs")
    func testBasicProfileCreation() throws {
        let profile = ProfileGenerator.makeProfile(
            preferences: [:],
            pumpSettings: TestInputs.settings,
            bgTargets: TestInputs.targets,
            basalProfile: TestInputs.basals,
            isf: TestInputs.isf,
            carbRatio: TestInputs.carbRatio,
            tempTargets: [:],
            model: "",
            autotune: nil,
            freeaps: [:]
        )
        
        #expect(profile.max_iob == 0)
        #expect(profile.dia == 3)
        #expect(profile.sens == 100)
        #expect(profile.current_basal == 1)
        #expect(profile.max_bg == 100)
        #expect(profile.min_bg == 100)
        #expect(profile.carb_ratio == 20)
    }
    
    @Test("Profile with temp target")
    func testProfileWithTempTarget() throws {
        let currentTime = Date()
        let creationDate = currentTime.addingTimeInterval(-5 * 60) // 5 minutes ago
        
        let tempTargets: [String: Any] = [
            "eventType": "Temporary Target",
            "reason": "Eating Soon",
            "targetTop": 80,
            "targetBottom": 80,
            "duration": 20,
            "created_at": creationDate
        ]
        
        let profile = ProfileGenerator.makeProfile(
            preferences: [:],
            pumpSettings: TestInputs.settings,
            bgTargets: TestInputs.targets,
            basalProfile: TestInputs.basals,
            isf: TestInputs.isf,
            carbRatio: TestInputs.carbRatio,
            tempTargets: tempTargets,
            model: "",
            autotune: nil,
            freeaps: [:]
        )
        
        #expect(profile.max_iob == 0)
        #expect(profile.dia == 3)
        #expect(profile.sens == 100)
        #expect(profile.current_basal == 1)
        #expect(profile.max_bg == 80)
        #expect(profile.min_bg == 80)
        #expect(profile.carb_ratio == 20)
        #expect(profile.temptargetSet == true)
    }
    
    @Test("Profile ignores expired temp target")
    func testProfileWithExpiredTempTarget() throws {
        let currentTime = Date()
        let pastDate = currentTime.addingTimeInterval(-90 * 60) // 90 minutes ago
        
        let tempTargets: [String: Any] = [
            "eventType": "Temporary Target",
            "reason": "Eating Soon",
            "targetTop": 80,
            "targetBottom": 80,
            "duration": 20,
            "created_at": pastDate
        ]
        
        let profile = ProfileGenerator.makeProfile(
            preferences: [:],
            pumpSettings: TestInputs.settings,
            bgTargets: TestInputs.targets,
            basalProfile: TestInputs.basals,
            isf: TestInputs.isf,
            carbRatio: TestInputs.carbRatio,
            tempTargets: tempTargets,
            model: "",
            autotune: nil,
            freeaps: [:]
        )
        
        #expect(profile.max_iob == 0)
        #expect(profile.dia == 3)
        #expect(profile.sens == 100)
        #expect(profile.current_basal == 1)
        #expect(profile.max_bg == 100)
        #expect(profile.min_bg == 100)
        #expect(profile.carb_ratio == 20)
    }
    
    @Test("Profile ignores zero duration temp target")
    func testProfileWithZeroDurationTempTarget() throws {
        let currentTime = Date()
        let creationDate = currentTime.addingTimeInterval(-5 * 60)
        
        let tempTargets: [String: Any] = [
            "eventType": "Temporary Target",
            "reason": "Eating Soon",
            "targetTop": 80,
            "targetBottom": 80,
            "duration": 0,
            "created_at": creationDate
        ]
        
        let profile = ProfileGenerator.makeProfile(
            preferences: [:],
            pumpSettings: TestInputs.settings,
            bgTargets: TestInputs.targets,
            basalProfile: TestInputs.basals,
            isf: TestInputs.isf,
            carbRatio: TestInputs.carbRatio,
            tempTargets: tempTargets,
            model: "",
            autotune: nil,
            freeaps: [:]
        )
        
        #expect(profile.max_iob == 0)
        #expect(profile.dia == 3)
        #expect(profile.sens == 100)
        #expect(profile.current_basal == 1)
        #expect(profile.max_bg == 100)
        #expect(profile.min_bg == 100)
        #expect(profile.carb_ratio == 20)
    }
    
    @Test("Profile fails with invalid DIA")
    func testProfileWithInvalidDIA() throws {
        var invalidSettings = TestInputs.settings
        invalidSettings["insulin_action_curve"] = Double(1)
        
        let profile = ProfileGenerator.makeProfile(
            preferences: [:],
            pumpSettings: invalidSettings,
            bgTargets: TestInputs.targets,
            basalProfile: TestInputs.basals,
            isf: TestInputs.isf,
            carbRatio: TestInputs.carbRatio,
            tempTargets: [:],
            model: "",
            autotune: nil,
            freeaps: [:]
        )
        
        #expect(profile.dia == 0)
    }
    
    @Test("Profile fails with zero current basal")
    func testProfileWithZeroBasal() throws {
        let zeroBasals = [BasalProfile(i: 0, minutes: 0, rate: 0, start: "00:00")]
        
        let profile = ProfileGenerator.makeProfile(
            preferences: [:],
            pumpSettings: TestInputs.settings,
            bgTargets: TestInputs.targets,
            basalProfile: zeroBasals,
            isf: TestInputs.isf,
            carbRatio: TestInputs.carbRatio,
            tempTargets: [:],
            model: "",
            autotune: nil,
            freeaps: [:]
        )
        
        #expect(profile.current_basal == 0)
    }
    
    @Test("Profile sets model from input")
    func testProfileSetsModel() throws {
        let profile = ProfileGenerator.makeProfile(
            preferences: [:],
            pumpSettings: TestInputs.settings,
            bgTargets: TestInputs.targets,
            basalProfile: TestInputs.basals,
            isf: TestInputs.isf,
            carbRatio: TestInputs.carbRatio,
            tempTargets: [:],
            model: "554",
            autotune: nil,
            freeaps: [:]
        )
        
        #expect(profile.modelString == "554")
    }
}
