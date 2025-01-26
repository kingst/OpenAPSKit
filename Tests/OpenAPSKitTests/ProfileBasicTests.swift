//
//  ProfileBasicTests.swift
//  OpenAPSKit
//
//  Created by Sam King on 1/26/25.
//

import Testing
import Foundation
@testable import OpenAPSKit

struct ProfileBasicTests {
    @Test("Checks to make sure that the defaults are correct")
    func testProfileDefaults() throws {
        guard let url = Bundle.module.url(forResource: "profileDefaults",   withExtension: "json") else {
            #expect(Bool(false), "Could not find profileDefaults.json")
            return
        }
           
        let jsDefaults = try String(contentsOf: url)
       
        let defaultProfile = Profile()
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let nativeDefaults = String(data: try encoder.encode(defaultProfile), encoding: .utf8)!
       
        let differences = try JSONCompare.differences(native: nativeDefaults, javascript: jsDefaults)
        #expect(differences.isEmpty, "Found differences between native and JS defaults: \(differences)")
        if !differences.isEmpty {
            JSONCompare.prettyPrintDifferences(differences)
        }
    }
}
