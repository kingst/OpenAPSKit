//
//  JSONCompare.swift
//  OpenAPSKit
//
//  Created by Sam King on 1/26/25.
//

import Foundation

struct JSONCompare {
    static func differences(native: String, javascript: String) throws -> [String: Any] {
        guard let jsData = javascript.data(using: .utf8),
              let nativeData = native.data(using: .utf8),
              let jsDict = try JSONSerialization.jsonObject(with: jsData) as? [String: Any],
              let nativeDict = try JSONSerialization.jsonObject(with: nativeData) as? [String: Any]
        else {
            throw NSError(domain: "JSONBridge", code: 1, userInfo: [NSLocalizedDescriptionKey: "Invalid JSON format"])
        }

        var differences: [String: Any] = [:]

        for (key, jsValue) in jsDict {
            if let nativeValue = nativeDict[key] {
                if !compareValues(jsValue, nativeValue) {
                    differences[key] = ["js": jsValue, "native": nativeValue]
                }
            } else {
                differences[key] = ["js": jsValue, "native": "missing"]
            }
        }

        for key in nativeDict.keys where !jsDict.keys.contains(key) {
            differences[key] = ["js": "missing", "native": nativeDict[key]]
        }

        return differences
    }

    private static func compareValues(_ value1: Any, _ value2: Any) -> Bool {
       guard type(of: value1) == type(of: value2) else { return false }
       
       switch (value1, value2) {
       case (is NSNull, is NSNull):
           return true
       case let (v1 as Bool, v2 as Bool):
           return v1 == v2
       case let (v1 as String, v2 as String):
           return v1 == v2
       case let (v1 as [Any], v2 as [Any]):
           guard v1.count == v2.count else { return false }
           return zip(v1, v2).allSatisfy { compareValues($0, $1) }
       case let (v1 as [String: Any], v2 as [String: Any]):
           guard v1.keys == v2.keys else { return false }
           return v1.keys.allSatisfy { key in
               guard let val1 = v1[key], let val2 = v2[key] else { return false }
               return compareValues(val1, val2)
           }
       case let (v1 as NSNumber, v2 as NSNumber):
           return v1.isEqual(v2) && v1.objCType == v2.objCType
       default:
           return false
       }
    }

    static func prettyPrintDifferences(_ differences: [String: Any], indent: String = "") {
        for (key, value) in differences {
            if let diffDict = value as? [String: Any] {
                print("\(indent)Key: \(key)")
                print("\(indent)  JS: \(diffDict["js"] ?? "nil")")
                print("\(indent)  Native: \(diffDict["native"] ?? "nil")")
            }
        }
    }
}
