//
//  ProfileGenerator.swift
//  OpenAPSKit
//
//  Created by Sam King on 1/21/25.
//
import Foundation

extension Profile {
    /// Updates profile properties from preferences where CodingKeys match
    /// This function ended up being pretty ugly, but I couldn't think of a cleaner
    /// way. I considered converting to JSON or using Mirror, but these weren't
    /// great so in the end I think that this approach is simpliest.
    ///
    /// Also, this implementation does _not_ copy any of the optional properties
    /// since these should get set in the `generate` method.
    mutating func update(from preferences: Preferences) {
        // Double properties
        maxIob = preferences.maxIOB
        min5mCarbImpact = preferences.min5mCarbimpact
        maxCOB = preferences.maxCOB
        maxDailySafetyMultiplier = preferences.maxDailySafetyMultiplier
        currentBasalSafetyMultiplier = preferences.currentBasalSafetyMultiplier
        autosensMax = preferences.autosensMax
        autosensMin = preferences.autosensMin
        halfBasalExerciseTarget = preferences.halfBasalExerciseTarget
        remainingCarbsCap = preferences.remainingCarbsCap
        smbInterval = preferences.smbInterval
        maxSMBBasalMinutes = preferences.maxSMBBasalMinutes
        maxUAMSMBBasalMinutes = preferences.maxUAMSMBBasalMinutes
        bolusIncrement = preferences.bolusIncrement
        carbsReqThreshold = preferences.carbsReqThreshold
        remainingCarbsFraction = preferences.remainingCarbsFraction
        enableSMBHighBgTarget = preferences.enableSMB_high_bg_target
        maxDeltaBgThreshold = preferences.maxDeltaBGthreshold
        insulinPeakTime = preferences.insulinPeakTime
        noisyCGMTargetMultiplier = preferences.noisyCGMTargetMultiplier
        adjustmentFactor = preferences.adjustmentFactor
        adjustmentFactorSigmoid = preferences.adjustmentFactorSigmoid
        weightPercentage = preferences.weightPercentage
        thresholdSetting = preferences.threshold_setting

        // Bool properties
        highTemptargetRaisesSensitivity = preferences.highTemptargetRaisesSensitivity
        lowTemptargetLowersSensitivity = preferences.lowTemptargetLowersSensitivity
        sensitivityRaisesTarget = preferences.sensitivityRaisesTarget
        resistanceLowersTarget = preferences.resistanceLowersTarget
        exerciseMode = preferences.exerciseMode
        skipNeutralTemps = preferences.skipNeutralTemps
        enableUAM = preferences.enableUAM
        a52RiskEnable = preferences.a52RiskEnable
        enableSMBWithCOB = preferences.enableSMBWithCOB
        enableSMBWithTemptarget = preferences.enableSMBWithTemptarget
        allowSMBWithHighTemptarget = preferences.allowSMBWithHighTemptarget
        enableSMBAlways = preferences.enableSMBAlways
        enableSMBAfterCarbs = preferences.enableSMBAfterCarbs
        rewindResetsAutosens = preferences.rewindResetsAutosens
        unsuspendIfNoTemp = preferences.unsuspendIfNoTemp
        enableSMBHighBg = preferences.enableSMB_high_bg
        useCustomPeakTime = preferences.useCustomPeakTime
        suspendZerosIob = preferences.suspendZerosIOB
        useNewFormula = preferences.useNewFormula
        enableDynamicCR = preferences.enableDynamicCR
        sigmoid = preferences.sigmoid
        tddAdjBasal = preferences.tddAdjBasal

        // Enum properties
        curve = preferences.curve
    }
}

public class ProfileGenerator {
    /// This function is a port of the prepare/profile.js function from Trio, and it calls the core OpenAPS function
    public static func generate(
        pumpSettings: PumpSettings,
        bgTargets: BGTargets,
        basalProfile: [BasalProfileEntry],
        isf: InsulinSensitivities,
        preferences: Preferences,
        carbRatios: CarbRatios,
        tempTargets: [TempTarget],
        model: String,
        autotune: Autotune?,
        freeaps: FreeAPSSettings
    ) throws -> Profile {
        let bgTargets = bgTargets.inMgDl()
        let isf = isf.inMgDl()
        let model = model.replacingOccurrences(of: "\"", with: "").trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard carbRatios.schedule.count > 0 else {
            throw ProfileError.invalidCarbRatio
        }
        
        var preferences = preferences
        switch (preferences.curve, preferences.useCustomPeakTime) {
        case (.rapidActing, true):
            preferences.insulinPeakTime = max(50, min(preferences.insulinPeakTime, 120))
        case (.rapidActing, false):
            preferences.insulinPeakTime = 75
        case (.ultraRapid, true):
            preferences.insulinPeakTime = max(35, min(preferences.insulinPeakTime, 100))
        case (.ultraRapid, false):
            preferences.insulinPeakTime = 55
        default:
            // don't do anything
            print("don't modify insulin peak time")
        }
        
        /* From Javascript
         for (var pref in preferences) {
           if (preferences.hasOwnProperty(pref)) {
             inputs[pref] = preferences[pref];
           }
         }

         inputs.max_iob = inputs.max_iob || 0;
         */
        // we don't need the JS logic above because it is handled by
        // our update function
        
        
        // in Trio it looks like autotune is always null
        /*
         var basalProfile = basalProfile
         var carbRatios = carbRatios
        if let autotune = autotune {
            if let basal = autotune.basalProfile {
                basalProfile = basal
            }
            // onlyAutotuneBasals is not defined in Swift
            if let isfProfile = autotune.isfProfile {
                // TODO: should we convert this to mg/dL as well?
                isf = isfProfile
            }
            if let carbRatio = autotune.carbRatio {
                carbRatios.schedule[0].ratio = carbRatio
            }
        }
         */
        return try generate(pumpSettings: pumpSettings, bgTargets: bgTargets, basalProfile: basalProfile, isf: isf, preferences: preferences, carbRatios: carbRatios, tempTargets: tempTargets, model: model)
    }
    
    /// Direct port of the OpenASP profile generate function
    static func generate(
        pumpSettings: PumpSettings,
        bgTargets: BGTargets,
        basalProfile: [BasalProfileEntry],
        isf: InsulinSensitivities,
        preferences: Preferences,
        carbRatios: CarbRatios,
        tempTargets: [TempTarget],
        model: String
    ) throws -> Profile {
        // var profile = opts && opts.type ? opts : defaults( );
        var profile = Profile() // uses defaults
        
        // check if inputs has overrides for any of the default prefs
        // and apply if applicable. Note, this comes from the generate/profile.js
        // where preferences get copied to the input then in the generate function
        // where it checks the input for properties that match the defaults
        profile.update(from: preferences)
        

        if pumpSettings.insulinActionCurve > 1 {
            profile.dia = pumpSettings.insulinActionCurve
        } else {
            throw ProfileError.invalidDIA(value: pumpSettings.insulinActionCurve)
        }
        
        profile.model = model
        profile.skipNeutralTemps = preferences.skipNeutralTemps
        
        profile.currentBasal = try Basal.basalLookup(basalProfile)
        profile.basalprofile = basalProfile
        
        let basalProfile = basalProfile.map { BasalProfileEntry(start: $0.start, minutes: $0.minutes, rate: Double(($0.rate * 1000).rounded()) / 1000 )}
        
        profile.maxDailyBasal = Basal.maxDailyBasal(basalProfile)
        profile.maxBasal = pumpSettings.maxBasal
        
        // this check is an error check profile.currentBasal === 0 in Javascript
        guard let currentBasal = profile.currentBasal, abs(currentBasal) > .ulpOfOne else {
            throw ProfileError.invalidCurrentBasal(value: profile.currentBasal)
        }
        
        guard let maxDailyBasal = profile.maxDailyBasal, abs(maxDailyBasal) > .ulpOfOne else {
            throw ProfileError.invalidMaxDailyBasal(value: profile.maxDailyBasal)
        }

        guard let maxBasal = profile.maxBasal, maxBasal >= 0.1 else {
            throw ProfileError.invalidMaxBasal(value: profile.maxBasal)
        }
        
        // var range = targets.bgTargetsLookup(inputs, profile);
        profile.outUnits = bgTargets.userPreferredUnits.rawValue
        let (updatedTargets, range) = try Targets.bgTargetsLookup(targets: bgTargets, tempTargets: tempTargets, profile: profile)
        // profile.min_bg = Math.round(range.min_bg);
        // profile.max_bg = Math.round(range.max_bg);
        profile.minBg = range.minBg?.rounded()
        profile.maxBg = range.maxBg?.rounded()
        // Note: we're using updatedTargets here because in Javascript the bgTargetsLookup
        // function mutates the input, so we want the mutated version in the
        // profile and we need to round the properties
        let roundedTargets = updatedTargets.targets.map { target -> ComputedBGTargetEntry in
            ComputedBGTargetEntry(
                low: target.low.rounded(),
                high: target.high.rounded(),
                start: target.start,
                offset: target.offset,
                maxBg: target.maxBg?.rounded(),
                minBg: target.minBg?.rounded(),
                temptargetSet: target.temptargetSet
            )
        }

        // Set the rounded targets on the profile
        profile.bgTargets = ComputedBGTargets(
            units: updatedTargets.units,
            userPreferredUnits: updatedTargets.userPreferredUnits,
            targets: roundedTargets
        )
        
        // delete profile.bg_targets.raw;
        // Note: we don't need this in Swift as we don't have the raw property
        
        profile.temptargetSet = range.temptargetSet
        let (sens, isfUpdated) = try Isf.isfLookup(isfData: isf)
        profile.sens = sens
        profile.isfProfile = isfUpdated
        
        guard let sens = profile.sens, sens >= 5 else {
            print("ISF of \(String(describing: profile.sens)) is not supported")
            throw ProfileError.invalidISF(value: profile.sens)
        }
        
        // Handle carb ratio data
        guard let currentCarbRatio = Carbs.carbRatioLookup(carbRatio: carbRatios) else {
            throw ProfileError.invalidCarbRatio
        }
        profile.carbRatio = currentCarbRatio
        profile.carbRatios = carbRatios
        
        return profile
    }
}
