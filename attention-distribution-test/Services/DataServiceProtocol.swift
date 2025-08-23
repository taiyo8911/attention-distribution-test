//
//  DataServiceProtocol.swift
//  attention-distribution-test
//
//  Created by Taiyo KOSHIBA on 2025/08/18.
//

import Foundation

// MARK: - Data Service Protocol
protocol DataServiceProtocol {
    func saveTestResult(_ result: TestResult) async throws
    func loadTestResults() async throws -> [TestResult]
}

// MARK: - Local Data Service Implementation
class DataService: DataServiceProtocol {

    // MARK: - Constants
    private static let testResultsKey = "TestResults"
    private static let maxResultsCount = 100

    // MARK: - Private Properties
    private let userDefaults: UserDefaults
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    // MARK: - Initializer
    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults

        // JSON encoder/decoder setup
        encoder.dateEncodingStrategy = .iso8601
        decoder.dateDecodingStrategy = .iso8601
    }

    // MARK: - Public Methods
    func saveTestResult(_ result: TestResult) async throws {
        var results = try await loadTestResults()

        // Add new result at the beginning
        results.insert(result, at: 0)

        // Limit to maximum count
        if results.count > Self.maxResultsCount {
            results = Array(results.prefix(Self.maxResultsCount))
        }

        let data = try encoder.encode(results)
        userDefaults.set(data, forKey: Self.testResultsKey)
        userDefaults.synchronize()

        print("Test result saved. Total results: \(results.count)")
    }

    func loadTestResults() async throws -> [TestResult] {
        guard let data = userDefaults.data(forKey: Self.testResultsKey) else {
            return []
        }

        let results = try decoder.decode([TestResult].self, from: data)
        print("Loaded \(results.count) test results")
        return results
    }
}

// MARK: - Mock Data Service (for testing/previews)
class MockDataService: DataServiceProtocol {
    private var mockResults: [TestResult] = []

    init(withMockData: Bool = true) {
        if withMockData {
            generateMockData()
        }
    }

    func saveTestResult(_ result: TestResult) async throws {
        mockResults.insert(result, at: 0)
        if mockResults.count > 100 {
            mockResults = Array(mockResults.prefix(100))
        }
    }

    func loadTestResults() async throws -> [TestResult] {
        return mockResults
    }

    private func generateMockData() {
        let now = Date()
        let calendar = Calendar.current

        for i in 0..<15 {
            let date = calendar.date(byAdding: .day, value: -i, to: now) ?? now
            let baseTime: TimeInterval = 120 + Double.random(in: -30...60) // 1:30 - 3:00
            let completionTime = max(60, baseTime)

            let startTime = date.addingTimeInterval(-completionTime)
            let result = TestResult(
                startTime: startTime,
                endTime: date,
                completionTime: completionTime
            )
            mockResults.append(result)
        }
    }
}
