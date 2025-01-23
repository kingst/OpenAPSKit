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
        autotuneIsfAdjustmentFraction = preferences.autotuneISFAdjustmentFraction
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
    
    /// Direct port of JavaScript's generate function
    public static func generate(
        pumpSettings: PumpSettings,
        bgTargets: BGTargets,
        basalProfile: [BasalProfileEntry],
        isf: InsulinSensitivities,
        preferences: Preferences,
        carbRatio: CarbRatios,
        tempTargets: TempTarget,
        model: String,
        autotune: [String: Any]?
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
        
        profile.modelString = model
        profile.skipNeutralTemps = preferences.skipNeutralTemps
        
        profile.currentBasal = basalLookup(basalProfile)
        profile.basalprofile = basalProfile
        
        let basalProfile = basalProfile.map { BasalProfileEntry(start: $0.start, minutes: $0.minutes, rate: Double(($0.rate * 1000).rounded()) / 1000 )}
        
        profile.maxDailyBasal = maxDailyBasal(basalProfile)
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
        let range = bgTargetsLookup(bgTargets, profile)
        
        // profile.out_units = inputs.targets.user_preferred_units;
        profile.out_units = bgTargets.userPreferredUnits.rawValue
        
        // profile.min_bg = Math.round(range.min_bg);
        // profile.max_bg = Math.round(range.max_bg);
        profile.min_bg = range.min_bg
        profile.max_bg = range.max_bg
        
        // profile.bg_targets = inputs.targets;
        profile.bg_targets = bgTargets
        
        // Round bg_targets values
        for index in 0..<bgTargets.targets.count {
            profile.bg_targets?.targets[index].high = bgTargets.targets[index].high.rounded()
            profile.bg_targets?.targets[index].low = bgTargets.targets[index].low.rounded()
            // bg_entry.min_bg = Math.round(bg_entry.min_bg);
            // bg_entry.max_bg = Math.round(bg_entry.max_bg);
            // min_bg and max_bg are both undefined in our inputs
        }
        
        // delete profile.bg_targets.raw;
        // Note: we don't need this in Swift as we don't have the raw property
        
        // profile.temptargetSet = range.temptargetSet;
        profile.temptargetSet = range.temptargetSet
        
        // profile.sens = isf.isfLookup(inputs.isf);
        profile.sens = isfLookup(isf)
        
        // profile.isfProfile = inputs.isf;
        profile.isfProfile = isf
        
        if profile.sens < 5 {
            print("ISF of \(profile.sens) is not supported")
            throw ProfileError.invalidISF(value: profile.sens)
        }
        
        // Handle carb ratio data
        profile.carb_ratio = carbRatioLookup(carbRatio)
        profile.carb_ratios = carbRatio
        
        return profile
    }
    
    private static func basalLookup(_ basalProfile: [BasalProfileEntry], now: Date? = nil) -> Double? {
        let nowDate = now ?? Date()
        
        // Original had a sort but it was a no-op if 'i' wasn't present, so we can skip it
        let basalProfileData = basalProfile
        
        guard let lastBasalRate = basalProfileData.last?.rate, lastBasalRate != 0 else {
            print("ERROR: bad basal schedule \(basalProfile)")
            return nil
        }
        
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: nowDate)
        let nowMinutes = (components.hour ?? 0) * 60 + (components.minute ?? 0)
        
        // Look for matching time slot
        for i in 0..<(basalProfileData.count - 1) {
            if nowMinutes >= basalProfileData[i].minutes &&
               nowMinutes < basalProfileData[i + 1].minutes {
                return Double(round(basalProfileData[i].rate * 1000)) / 1000
            }
        }
        
        // If no matching slot found, return last basal rate
        return Double(round(lastBasalRate * 1000)) / 1000
    }
    
    private static func maxDailyBasal(_ basalProfile: [BasalProfileEntry]) -> Double? {
        guard let maxBasal = basalProfile.map({ $0.rate }).max() else {
            return nil
        }
        
        // In Javascript Number is floating point, so we don't need to do
        // the * 1000 / 1000
        return maxBasal
    }
    
    private static func bgTargetsLookup(_ bgTargets: BGTargets, _ profile: Profile) -> (min_bg: Int, max_bg: Int, temptargetSet: Bool) {
        // Port of targets.bgTargetsLookup
        return (0, 0, false)  // Placeholder
    }
    
    private static func isfLookup(_ isf: InsulinSensitivities) -> Double {
        // Port of isf.isfLookup
        return 0  // Placeholder
    }
    
    private static func carbRatioLookup(_ carbRatio: CarbRatios) -> Double {
        // Port of carb_ratios.carbRatioLookup
        return 0  // Placeholder
    }
}
