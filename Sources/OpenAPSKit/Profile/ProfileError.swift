//
//  ProfileError.swift
//  OpenAPSKit
//
//  Created by Sam King on 1/22/25.
//

import Foundation

public enum ProfileError: LocalizedError, Equatable {
    case invalidDIA(value: Double)
    case invalidCurrentBasal(value: Double?)
    case invalidMaxDailyBasal(value: Double?)
    case invalidMaxBasal(value: Double?)
    case invalidISF(value: Double?)
    case invalidCarbRatio
    
    public var errorDescription: String? {
        switch self {
        case .invalidDIA(let value):
            return "DIA of \(String(describing: value)) is not supported (must be > 1)"
        case .invalidCurrentBasal(let value):
            return "Current basal of \(String(describing: value)) is not supported (must be > 0)"
        case .invalidMaxDailyBasal(let value):
            return "Max daily basal of \(String(describing: value)) is not supported (must be > 0)"
        case .invalidMaxBasal(let value):
            return "Max basal of \(String(describing: value)) is not supported (must be >= 0.1)"
        case .invalidISF(let value):
            return "ISF of \(String(describing: value)) is not supported (must be >= 5)"
        case .invalidCarbRatio:
            return "Profile wasn't given carb ratio data, cannot calculate carb_ratio"
        }
    }
}