import Foundation

public struct Preferences: Codable {
    var maxIOB: Double = 0
    var maxDailySafetyMultiplier: Double = 3
    var currentBasalSafetyMultiplier: Double = 4
    var autosensMax: Double = 1.2
    var autosensMin: Double = 0.7
    var smbDeliveryRatio: Double = 0.5
    var rewindResetsAutosens: Bool = true
    var highTemptargetRaisesSensitivity: Bool = false
    var lowTemptargetLowersSensitivity: Bool = false
    var sensitivityRaisesTarget: Bool = false
    var resistanceLowersTarget: Bool = false
    var advTargetAdjustments: Bool = false
    var exerciseMode: Bool = false
    var halfBasalExerciseTarget: Double = 160
    var maxCOB: Double = 120
    var wideBGTargetRange: Bool = false
    var skipNeutralTemps: Bool = false
    var unsuspendIfNoTemp: Bool = false
    var min5mCarbimpact: Double = 8
    var remainingCarbsFraction: Double = 1.0
    var remainingCarbsCap: Double = 90
    var enableUAM: Bool = false
    var a52RiskEnable: Bool = false
    var enableSMBWithCOB: Bool = false
    var enableSMBWithTemptarget: Bool = false
    var enableSMBAlways: Bool = false
    var enableSMBAfterCarbs: Bool = false
    var allowSMBWithHighTemptarget: Bool = false
    var maxSMBBasalMinutes: Double = 30
    var maxUAMSMBBasalMinutes: Double = 30
    var smbInterval: Double = 3
    var bolusIncrement: Double = 0.1
    var curve: InsulinCurve = .rapidActing
    var useCustomPeakTime: Bool = false
    var insulinPeakTime: Double = 75
    var carbsReqThreshold: Double = 1.0
    var noisyCGMTargetMultiplier: Double = 1.3
    var suspendZerosIOB: Bool = false
    var timestamp: Date?
    var maxDeltaBGthreshold: Double = 0.2
    var adjustmentFactor: Double = 0.8
    var adjustmentFactorSigmoid: Double = 0.5
    var sigmoid: Bool = false
    var enableDynamicCR: Bool = false
    var useNewFormula: Bool = false
    var useWeightedAverage: Bool = false
    var weightPercentage: Double = 0.65
    var tddAdjBasal: Bool = false
    var enableSMB_high_bg: Bool = false
    var enableSMB_high_bg_target: Double = 110
    var threshold_setting: Double = 65
    var updateInterval: Double = 20
}

extension Preferences {
    private enum CodingKeys: String, CodingKey {
        case maxIOB = "max_iob"
        case maxDailySafetyMultiplier = "max_daily_safety_multiplier"
        case currentBasalSafetyMultiplier = "current_basal_safety_multiplier"
        case autosensMax = "autosens_max"
        case autosensMin = "autosens_min"
        case smbDeliveryRatio = "smb_delivery_ratio"
        case rewindResetsAutosens = "rewind_resets_autosens"
        case highTemptargetRaisesSensitivity = "high_temptarget_raises_sensitivity"
        case lowTemptargetLowersSensitivity = "low_temptarget_lowers_sensitivity"
        case sensitivityRaisesTarget = "sensitivity_raises_target"
        case resistanceLowersTarget = "resistance_lowers_target"
        case advTargetAdjustments = "adv_target_adjustments"
        case exerciseMode = "exercise_mode"
        case halfBasalExerciseTarget = "half_basal_exercise_target"
        case maxCOB
        case wideBGTargetRange = "wide_bg_target_range"
        case skipNeutralTemps = "skip_neutral_temps"
        case unsuspendIfNoTemp = "unsuspend_if_no_temp"
        case min5mCarbimpact = "min_5m_carbimpact"
        case remainingCarbsFraction
        case remainingCarbsCap
        case enableUAM
        case a52RiskEnable = "A52_risk_enable"
        case enableSMBWithCOB = "enableSMB_with_COB"
        case enableSMBWithTemptarget = "enableSMB_with_temptarget"
        case enableSMBAlways = "enableSMB_always"
        case enableSMBAfterCarbs = "enableSMB_after_carbs"
        case allowSMBWithHighTemptarget = "allowSMB_with_high_temptarget"
        case maxSMBBasalMinutes
        case maxUAMSMBBasalMinutes
        case smbInterval = "SMBInterval"
        case bolusIncrement = "bolus_increment"
        case curve
        case useCustomPeakTime
        case insulinPeakTime
        case carbsReqThreshold
        case noisyCGMTargetMultiplier
        case suspendZerosIOB = "suspend_zeros_iob"
        case maxDeltaBGthreshold = "maxDelta_bg_threshold"
        case adjustmentFactor
        case adjustmentFactorSigmoid
        case sigmoid
        case enableDynamicCR
        case useNewFormula
        case useWeightedAverage
        case weightPercentage
        case tddAdjBasal
        case enableSMB_high_bg
        case enableSMB_high_bg_target
        case threshold_setting
        case updateInterval
    }
}

public enum InsulinCurve: String, Codable, Identifiable, CaseIterable {
    case rapidActing = "rapid-acting"
    case ultraRapid = "ultra-rapid"
    case bilinear

    public var id: InsulinCurve { self }
}
