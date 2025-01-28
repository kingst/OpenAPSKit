//
//  ResultLogger.swift
//  OpenAPSKit
//
//  Created by Sam King on 1/28/25.
//

import Foundation
import UIKit

struct AlgorithmComparison: Codable {
    let id: UUID
    let createdAt: Date
    let label: String
    let difference: [String: ValueDifference]
    let jsDuration: TimeInterval
    let nativeDuration: TimeInterval
}

struct ComparisonBatch: Codable {
    let userId: String
    let deviceInfo: DeviceInfo
    let appVersion: String
    let comparisons: [AlgorithmComparison]
}

struct DeviceInfo: Codable {
    let model: String
    let osVersion: String
}

enum LoggerError: Error {
    case fileOperationFailed
    case encodingFailed
    case decodingFailed
}

actor AlgorithmLogger {
    private let minBatchSize = 6
    private let maxStoredEntries = 72
    private let fileManager = FileManager.default
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    
    private let userId: String
    private let getAppendUrl: () async throws -> URL
    private let storageUrl: URL
    
    init(userId: String, getAppendUrl: @escaping () async throws -> URL) throws {
        self.userId = userId
        self.getAppendUrl = getAppendUrl
        
        encoder.dateEncodingStrategy = .secondsSince1970
        decoder.dateDecodingStrategy = .secondsSince1970
        
        guard let documentsPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            throw LoggerError.fileOperationFailed
        }
        
        self.storageUrl = documentsPath.appendingPathComponent("algorithm_comparisons.json")
        
        if !fileManager.fileExists(atPath: storageUrl.path) {
            try "[]".write(to: storageUrl, atomically: true, encoding: .utf8)
        }
    }
    
    private func readComparisons() throws -> [AlgorithmComparison] {
        let data = try Data(contentsOf: storageUrl)
        return try decoder.decode([AlgorithmComparison].self, from: data)
    }
    
    private func writeComparisons(_ comparisons: [AlgorithmComparison]) throws {
        let data = try encoder.encode(comparisons)
        try data.write(to: storageUrl, options: .atomicWrite)
    }
    
    func logComparison(
        label: String,
        difference: [String: ValueDifference],
        jsDuration: TimeInterval,
        nativeDuration: TimeInterval
    ) async throws {
        let comparison = AlgorithmComparison(
            id: UUID(),
            createdAt: Date(),
            label: label,
            difference: difference,
            jsDuration: jsDuration,
            nativeDuration: nativeDuration
        )
        
        var comparisons = try readComparisons()
        comparisons.append(comparison)
        if comparisons.count > maxStoredEntries {
            comparisons.removeFirst(comparisons.count - maxStoredEntries)
        }
        
        try writeComparisons(comparisons)
        
        if comparisons.count >= minBatchSize {
            try await uploadCurrentBatch()
        }
    }
    
    private func uploadCurrentBatch() async throws {
        let comparisons = try readComparisons()
        guard comparisons.count >= minBatchSize else { return }
        
        let comparisonsToUpload = Array(comparisons.prefix(min(comparisons.count, maxStoredEntries)))
        let uploadedIds = Set(comparisonsToUpload.map { $0.id })
        
        let batch = await ComparisonBatch(
            userId: userId,
            deviceInfo: DeviceInfo(
                model: UIDevice.current.model,
                osVersion: UIDevice.current.systemVersion
            ),
            appVersion: Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "unknown",
            comparisons: comparisonsToUpload
        )
        
        let url = try await getAppendUrl()
        try await uploadBatch(batch, to: url)
        
        var updatedComparisons = try readComparisons()
        updatedComparisons.removeAll(where: { uploadedIds.contains($0.id) })
        try writeComparisons(updatedComparisons)
    }
    
    private func uploadBatch(_ batch: ComparisonBatch, to url: URL) async throws {
        let data = try encoder.encode(batch)
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let (_, response) = try await URLSession.shared.upload(for: request, from: data)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }
    }
    
    func getStatus() async throws -> (stored: Int, canUpload: Bool) {
        let comparisons = try readComparisons()
        return (comparisons.count, comparisons.count >= minBatchSize)
    }
}
