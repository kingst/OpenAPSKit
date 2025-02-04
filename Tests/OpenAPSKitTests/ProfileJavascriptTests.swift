//
//  ProfileJavascriptTests.swift
//  OpenAPSKit
//
//  Created by Sam King on 1/21/25.
//

import Testing
import Foundation
@testable import OpenAPSKit

struct ProfileGeneratorTests {
    // Base test inputs that match the JavaScript test setup
    private func createBaseInputs() -> (
        OKPumpSettings,
        OKBGTargets,
        [OKBasalProfileEntry],
        OKInsulinSensitivities,
        OKPreferences,
        OKCarbRatios,
        [OKTempTarget],
        String,
        OKAutotune?,
        OKFreeAPSSettings
    ) {
        let pumpSettings = OKPumpSettings(
            insulinActionCurve: 3,
            maxBolus: 10,
            maxBasal: 2
        )
        
        let bgTargets = OKBGTargets(
            units: .mgdL,
            userPreferredUnits: .mgdL,
            targets: [
                OKBGTargetEntry(low: 100, high: 120, start: "00:00", offset: 0)
            ]
        )
        
        let basalProfile = [
            OKBasalProfileEntry(start: "00:00", minutes: 0, rate: 1.0)
        ]
        
        let isf = OKInsulinSensitivities(
            units: .mgdL,
            userPreferredUnits: .mgdL,
            sensitivities: [
                OKInsulinSensitivityEntry(sensitivity: 100, offset: 0, start: "00:00")
            ]
        )
        
        let preferences = OKPreferences()
        
        let carbRatios = OKCarbRatios(
            units: .grams,
            schedule: [
                OKCarbRatioEntry(start: "00:00", offset: 0, ratio: 20)
            ]
        )
        
        let tempTargets: [OKTempTarget] = []
        let model = "523"
        let autotune: OKAutotune? = nil
        let freeaps = OKFreeAPSSettings()
        
        return (pumpSettings, bgTargets, basalProfile, isf, preferences, carbRatios, tempTargets, model, autotune, freeaps)
    }
    
    @Test("Basic profile generation should create profile with correct values")
    func testBasicProfileGeneration() throws {
        let inputs = createBaseInputs()
        
        let profile = try ProfileGenerator.generate(
            pumpSettings: inputs.0,
            bgTargets: inputs.1,
            basalProfile: inputs.2,
            isf: inputs.3,
            preferences: inputs.4,
            carbRatios: inputs.5,
            tempTargets: inputs.6,
            model: inputs.7,
            autotune: inputs.8,
            freeaps: inputs.9
        )
        
        #expect(profile.maxIob == 0)
        #expect(profile.dia == 3)
        #expect(profile.sens == 100)
        #expect(profile.currentBasal == 1)
        #expect(profile.maxBg == 100)
        #expect(profile.minBg == 100)
        #expect(profile.carbRatio == 20)
    }
    
    @Test("Profile with active temp target should use temp target values")
    func testProfileWithTempTarget() throws {
        var inputs = createBaseInputs()
        
        // Create temp target 5 minutes ago that lasts 20 minutes
        let currentTime = Date()
        let creationDate = currentTime.addingTimeInterval(-5 * 60)
        
        let tempTarget = OKTempTarget(
            name: "Eating Soon",
            createdAt: creationDate,
            targetTop: 80,
            targetBottom: 80,
            duration: 20,
            enteredBy: "Test",
            reason: "Eating Soon"
        )
        
        inputs.6 = [tempTarget]
        
        let profile = try ProfileGenerator.generate(
            pumpSettings: inputs.0,
            bgTargets: inputs.1,
            basalProfile: inputs.2,
            isf: inputs.3,
            preferences: inputs.4,
            carbRatios: inputs.5,
            tempTargets: inputs.6,
            model: inputs.7,
            autotune: inputs.8,
            freeaps: inputs.9
        )
        
        #expect(profile.maxIob == 0)
        #expect(profile.dia == 3)
        #expect(profile.sens == 100)
        #expect(profile.currentBasal == 1)
        #expect(profile.maxBg == 80)
        #expect(profile.minBg == 80)
        #expect(profile.carbRatio == 20)
        #expect(profile.temptargetSet == true)
    }
    
    @Test("Profile with expired temp target should use default values")
    func testProfileWithExpiredTempTarget() throws {
        var inputs = createBaseInputs()
        
        // Create temp target 90 minutes ago
        let currentTime = Date()
        let creationDate = currentTime.addingTimeInterval(-90 * 60)
        
        let tempTarget = OKTempTarget(
            name: "Eating Soon",
            createdAt: creationDate,
            targetTop: 80,
            targetBottom: 80,
            duration: 20,
            enteredBy: "Test",
            reason: "Eating Soon"
        )
        
        inputs.6 = [tempTarget]
        
        let profile = try ProfileGenerator.generate(
            pumpSettings: inputs.0,
            bgTargets: inputs.1,
            basalProfile: inputs.2,
            isf: inputs.3,
            preferences: inputs.4,
            carbRatios: inputs.5,
            tempTargets: inputs.6,
            model: inputs.7,
            autotune: inputs.8,
            freeaps: inputs.9
        )
        
        #expect(profile.maxIob == 0)
        #expect(profile.dia == 3)
        #expect(profile.sens == 100)
        #expect(profile.currentBasal == 1)
        #expect(profile.maxBg == 100)
        #expect(profile.minBg == 100)
        #expect(profile.carbRatio == 20)
    }
    
    @Test("Profile with zero duration temp target should use default values")
    func testProfileWithZeroDurationTempTarget() throws {
        var inputs = createBaseInputs()
        
        // Create temp target 5 minutes ago with 0 duration
        let currentTime = Date()
        let creationDate = currentTime.addingTimeInterval(-5 * 60)
        
        let tempTarget = OKTempTarget(
            name: "Eating Soon",
            createdAt: creationDate,
            targetTop: 80,
            targetBottom: 80,
            duration: 0,
            enteredBy: "Test",
            reason: "Eating Soon"
        )
        
        inputs.6 = [tempTarget]
        
        let profile = try ProfileGenerator.generate(
            pumpSettings: inputs.0,
            bgTargets: inputs.1,
            basalProfile: inputs.2,
            isf: inputs.3,
            preferences: inputs.4,
            carbRatios: inputs.5,
            tempTargets: inputs.6,
            model: inputs.7,
            autotune: inputs.8,
            freeaps: inputs.9
        )
        
        #expect(profile.maxIob == 0)
        #expect(profile.dia == 3)
        #expect(profile.sens == 100)
        #expect(profile.currentBasal == 1)
        #expect(profile.maxBg == 100)
        #expect(profile.minBg == 100)
        #expect(profile.carbRatio == 20)
    }
    
    @Test("Profile generation with invalid DIA should throw error")
    func testInvalidDIA() throws {
        var inputs = createBaseInputs()
        inputs.0 = OKPumpSettings(
            insulinActionCurve: 1,
            maxBolus: 10,
            maxBasal: 2
        )
        
        #expect(throws: ProfileError.invalidDIA(value: 1)) {
            _ = try ProfileGenerator.generate(
                pumpSettings: inputs.0,
                bgTargets: inputs.1,
                basalProfile: inputs.2,
                isf: inputs.3,
                preferences: inputs.4,
                carbRatios: inputs.5,
                tempTargets: inputs.6,
                model: inputs.7,
                autotune: inputs.8,
                freeaps: inputs.9
            )
        }
    }
    
    @Test("Profile generation with zero basal rate should throw error")
    func testCurrentBasalZero() throws {
        var inputs = createBaseInputs()
        inputs.2 = [
            OKBasalProfileEntry(start: "00:00", minutes: 0, rate: 0.0)
        ]
        
        #expect(throws: ProfileError.invalidCurrentBasal(value: nil)) {
            _ = try ProfileGenerator.generate(
                pumpSettings: inputs.0,
                bgTargets: inputs.1,
                basalProfile: inputs.2,
                isf: inputs.3,
                preferences: inputs.4,
                carbRatios: inputs.5,
                tempTargets: inputs.6,
                model: inputs.7,
                autotune: inputs.8,
                freeaps: inputs.9
            )
        }
    }
    
    @Test("Profile should store model string correctly")
    func testModelString() throws {
        var inputs = createBaseInputs()
        inputs.7 = "\"554\"\n"
        
        let profile = try ProfileGenerator.generate(
            pumpSettings: inputs.0,
            bgTargets: inputs.1,
            basalProfile: inputs.2,
            isf: inputs.3,
            preferences: inputs.4,
            carbRatios: inputs.5,
            tempTargets: inputs.6,
            model: inputs.7,
            autotune: inputs.8,
            freeaps: inputs.9
        )
        
        #expect(profile.model == "554")
    }
}
