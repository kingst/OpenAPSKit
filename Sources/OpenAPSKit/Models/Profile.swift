//
//  Profile.swift
//  OpenAPSKit
//
//  Created by Sam King on 1/21/25.
//
// For this Profile struct, any properties that don't
// have default values are set as optional, but we check
// that they actually get set when we encode this to JSON.
// This technique isn't great, but it helps so that we
// can do a line-by-line port of the generation logic, and
// doing it line-by-line will help simplify.

import Foundation

public struct Profile: Codable {
    // Kotlin-defined properties from AndroidAPS OapsProfile.kt
    // with defaults pulled from profile.js
    public var dia: Double?
    public var min5mCarbImpact: Double = 8
    public var maxIob: Double = 0 // if max_iob is not provided, will default to zero
    public var maxDailyBasal: Double?
    public var maxBasal: Double?
    public var minBg: Double?
    public var maxBg: Double?
    @JavascriptOptional public var targetBg: Double?
    public var smbDeliveryRatio: Double = 0.5
    public var carbRatio: Double?
    public var sens: Double?
    public var maxDailySafetyMultiplier: Double = 3
    public var currentBasalSafetyMultiplier: Double = 4
    public var highTemptargetRaisesSensitivity: Bool = false // raise sensitivity for temptargets >= 101
    public var lowTemptargetLowersSensitivity: Bool = false // lower sensitivity for temptargets <= 99
    public var sensitivityRaisesTarget: Bool = false // raise BG target when autosens detects sensitivity
    public var resistanceLowersTarget: Bool = false // lower BG target when autosens detects resistance
    public var exerciseMode: Bool = false // when true, > 100 mg/dL high temp target adjusts sensitivityRatio
    public var halfBasalExerciseTarget: Double = 160 // when temptarget is 160 mg/dL *and* exercise_mode=true, run 50% basal
    public var maxCOB: Double = 120 // maximum carbs a typical body can absorb over 4 hours
    public var skipNeutralTemps: Bool = false
    public var remainingCarbsCap: Double = 90
    public var enableUAM: Bool = false
    public var a52RiskEnable: Bool = false
    public var smbInterval: Double = 3
    public var enableSMBWithCOB: Bool = false
    public var enableSMBWithTemptarget: Bool = false
    public var allowSMBWithHighTemptarget: Bool = false
    public var enableSMBAlways: Bool = false
    public var enableSMBAfterCarbs: Bool = false
    public var maxSMBBasalMinutes: Double = 30
    public var maxUAMSMBBasalMinutes: Double = 30
    public var bolusIncrement: Double = 0.1
    public var carbsReqThreshold: Double = 1
    public var currentBasal: Double?
    public var temptargetSet: Bool?
    public var autosensMax: Double = 1.2
    public var outUnits: String?

    // Additional properties
    public var autosensMin: Double = 0.7
    public var rewindResetsAutosens: Bool = true
    public var remainingCarbsFraction: Double = 1.0
    public var unsuspendIfNoTemp: Bool = false
    public var autotuneIsfAdjustmentFraction: Double = 1.0
    public var enableSMBHighBg: Bool = false
    public var enableSMBHighBgTarget: Double = 110
    public var maxDeltaBgThreshold: Double = 0.2
    public var curve: InsulinCurve = .rapidActing
    public var useCustomPeakTime: Bool = false
    public var insulinPeakTime: Double = 75
    public var offlineHotspot: Bool = false
    public var noisyCGMTargetMultiplier: Double = 1.3
    public var suspendZerosIob: Bool = true
    public var enableEnliteBgproxy: Bool = false
    public var calcGlucoseNoise: Bool = false
    public var adjustmentFactor: Double = 0.8
    public var adjustmentFactorSigmoid: Double = 0.5
    public var useNewFormula: Bool = false
    public var enableDynamicCR: Bool = false
    public var sigmoid: Bool = false
    public var weightPercentage: Double = 0.65
    public var tddAdjBasal: Bool = false
    public var thresholdSetting: Double = 60
    public var model: String?
    public var basalprofile: [BasalProfileEntry]?
    public var isfProfile: InsulinSensitivities?
    public var bgTargets: ComputedBGTargets?
    public var carbRatios: CarbRatios?

    private enum CodingKeys: String, CodingKey {
        case dia
        case min5mCarbImpact = "min_5m_carbimpact"
        case maxIob = "max_iob"
        case maxDailyBasal = "max_daily_basal"
        case maxBasal = "max_basal"
        case minBg = "min_bg"
        case maxBg = "max_bg"
        case targetBg = "target_bg"
        case smbDeliveryRatio = "smb_delivery_ratio"
        case carbRatio = "carb_ratio"
        case sens
        case maxDailySafetyMultiplier = "max_daily_safety_multiplier"
        case currentBasalSafetyMultiplier = "current_basal_safety_multiplier"
        case highTemptargetRaisesSensitivity = "high_temptarget_raises_sensitivity"
        case lowTemptargetLowersSensitivity = "low_temptarget_lowers_sensitivity"
        case sensitivityRaisesTarget = "sensitivity_raises_target"
        case resistanceLowersTarget = "resistance_lowers_target"
        case exerciseMode = "exercise_mode"
        case halfBasalExerciseTarget = "half_basal_exercise_target"
        case maxCOB
        case skipNeutralTemps = "skip_neutral_temps"
        case remainingCarbsCap
        case enableUAM
        case a52RiskEnable = "A52_risk_enable"
        case smbInterval = "SMBInterval"
        case enableSMBWithCOB = "enableSMB_with_COB"
        case enableSMBWithTemptarget = "enableSMB_with_temptarget"
        case allowSMBWithHighTemptarget = "allowSMB_with_high_temptarget"
        case enableSMBAlways = "enableSMB_always"
        case enableSMBAfterCarbs = "enableSMB_after_carbs"
        case maxSMBBasalMinutes
        case maxUAMSMBBasalMinutes
        case bolusIncrement = "bolus_increment"
        case carbsReqThreshold
        case currentBasal = "current_basal"
        case temptargetSet
        case autosensMax = "autosens_max"
        case outUnits = "out_units"
        case autosensMin = "autosens_min"
        case rewindResetsAutosens = "rewind_resets_autosens"
        case remainingCarbsFraction
        case unsuspendIfNoTemp = "unsuspend_if_no_temp"
        case autotuneIsfAdjustmentFraction = "autotune_isf_adjustmentFraction"
        case enableSMBHighBg = "enableSMB_high_bg"
        case enableSMBHighBgTarget = "enableSMB_high_bg_target"
        case maxDeltaBgThreshold = "maxDelta_bg_threshold"
        case curve
        case useCustomPeakTime
        case insulinPeakTime
        case offlineHotspot = "offline_hotspot"
        case noisyCGMTargetMultiplier
        case suspendZerosIob = "suspend_zeros_iob"
        case enableEnliteBgproxy
        case calcGlucoseNoise = "calc_glucose_noise"
        case adjustmentFactor
        case adjustmentFactorSigmoid
        case useNewFormula
        case enableDynamicCR
        case sigmoid
        case weightPercentage
        case tddAdjBasal
        case thresholdSetting = "threshold_setting"
        case model
        case basalprofile
        case isfProfile
        case bgTargets = "bg_targets"
        case carbRatios = "carb_ratios"
    }
}
