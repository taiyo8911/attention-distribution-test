//
//  DataServiceProtocol.swift
//  attention-distribution-test
//
//  Created by Taiyo KOSHIBA on 2025/08/18.
//


import Foundation
import CryptoKit

// MARK: - Data Service Protocol
protocol DataServiceProtocol {
    func saveTestResult(_ result: TestResult) async throws
    func loadTestResults() async throws -> [TestResult]
    func deleteTestResult(id: UUID) async throws
    func clearAllResults() async throws
    func exportResults(format: ExportFormat) async throws -> Data
}

// MARK: - Export Formats
enum ExportFormat {
    case json
    case csv
    
    var fileExtension: String {
        switch self {
        case .json: return "json"
        case .csv: return "csv"
        }
    }
    
    var mimeType: String {
        switch self {
        case .json: return "application/json"
        case .csv: return "text/csv"
        }
    }
}

// MARK: - Data Service Errors
enum DataServiceError: LocalizedError {
    case encryptionFailed
    case decryptionFailed
    case invalidData
    case storageLimit
    case fileSystemError
    
    var errorDescription: String? {
        switch self {
        case .encryptionFailed:
            return "データの暗号化に失敗しました"
        case .decryptionFailed:
            return "データの復号化に失敗しました"
        case .invalidData:
            return "無効なデータ形式です"
        case .storageLimit:
            return "ストレージ容量の上限に達しました"
        case .fileSystemError:
            return "ファイルシステムエラーが発生しました"
        }
    }
}

// MARK: - Local Data Service Implementation
class DataService: DataServiceProtocol {
    
    // MARK: - Constants
    private enum Constants {
        static let testResultsKey = "TestResults_v2"
        static let maxResultsCount = 100
        static let encryptionKey = "AttentionDistributionTestEncryptionKey"
    }
    
    // MARK: - Private Properties
    private let userDefaults: UserDefaults
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder
    private let encryptionKey: SymmetricKey
    
    // MARK: - Initializer
    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
        
        // JSON encoder/decoder setup
        self.encoder = JSONEncoder()
        self.encoder.dateEncodingStrategy = .iso8601
        
        self.decoder = JSONDecoder()
        self.decoder.dateDecodingStrategy = .iso8601
        
        // Encryption key setup
        let keyData = Constants.encryptionKey.data(using: .utf8) ?? Data()
        self.encryptionKey = SymmetricKey(data: SHA256.hash(data: keyData))
    }
    
    // MARK: - Public Methods
    func saveTestResult(_ result: TestResult) async throws {
        var results = try await loadTestResults()
        
        // Add new result at the beginning
        results.insert(result, at: 0)
        
        // Limit to maximum count
        if results.count > Constants.maxResultsCount {
            results = Array(results.prefix(Constants.maxResultsCount))
        }
        
        try await saveResults(results)
        
        print("Test result saved. Total results: \(results.count)")
    }
    
    func loadTestResults() async throws -> [TestResult] {
        guard let encryptedData = userDefaults.data(forKey: Constants.testResultsKey) else {
            return []
        }
        
        do {
            let decryptedData = try decrypt(encryptedData)
            let results = try decoder.decode([TestResult].self, from: decryptedData)
            
            print("Loaded \(results.count) test results")
            return results
        } catch {
            print("Failed to load test results: \(error)")
            
            // Try to load legacy data format
            if let legacyResults = try? loadLegacyResults() {
                // Migrate to new format
                try await saveResults(legacyResults)
                return legacyResults
            }
            
            throw DataServiceError.decryptionFailed
        }
    }
    
    func deleteTestResult(id: UUID) async throws {
        var results = try await loadTestResults()
        results.removeAll { $0.id == id }
        try await saveResults(results)
        
        print("Test result deleted. Remaining results: \(results.count)")
    }
    
    func clearAllResults() async throws {
        userDefaults.removeObject(forKey: Constants.testResultsKey)
        userDefaults.removeObject(forKey: "TestHistory") // Legacy key
        
        print("All test results cleared")
    }
    
    func exportResults(format: ExportFormat) async throws -> Data {
        let results = try await loadTestResults()
        
        switch format {
        case .json:
            return try encoder.encode(results)
        case .csv:
            return try generateCSV(from: results)
        }
    }
    
    // MARK: - Private Methods
    private func saveResults(_ results: [TestResult]) async throws {
        let data = try encoder.encode(results)
        let encryptedData = try encrypt(data)
        
        userDefaults.set(encryptedData, forKey: Constants.testResultsKey)
        
        // Force synchronization
        userDefaults.synchronize()
    }
    
    private func encrypt(_ data: Data) throws -> Data {
        do {
            let sealedBox = try AES.GCM.seal(data, using: encryptionKey)
            return sealedBox.combined ?? Data()
        } catch {
            throw DataServiceError.encryptionFailed
        }
    }
    
    private func decrypt(_ data: Data) throws -> Data {
        do {
            let sealedBox = try AES.GCM.SealedBox(combined: data)
            return try AES.GCM.open(sealedBox, using: encryptionKey)
        } catch {
            throw DataServiceError.decryptionFailed
        }
    }
    
    private func loadLegacyResults() throws -> [TestResult] {
        guard let data = userDefaults.data(forKey: "TestHistory") else {
            return []
        }
        
        // Try to decode legacy format
        struct LegacyTestResult: Codable {
            let date: Date
            let completionTime: TimeInterval
            let deviceType: String
        }
        
        let legacyResults = try decoder.decode([LegacyTestResult].self, from: data)
        return legacyResults.map { legacy in
            TestResult(
                date: legacy.date,
                completionTime: legacy.completionTime,
                deviceType: legacy.deviceType
            )
        }
    }
    
    private func generateCSV(from results: [TestResult]) throws -> Data {
        var csvContent = "ID,Date,CompletionTime,DeviceType,DeviceModel,AppVersion,StartTime,EndTime\n"
        
        let dateFormatter = ISO8601DateFormatter()
        
        for result in results {
            let row = [
                result.id.uuidString,
                dateFormatter.string(from: result.date),
                String(result.completionTime),
                result.deviceType.rawValue,
                result.deviceModel,
                result.appVersion,
                dateFormatter.string(from: result.startTime),
                dateFormatter.string(from: result.endTime)
            ].joined(separator: ",")
            
            csvContent += row + "\n"
        }
        
        guard let data = csvContent.data(using: .utf8) else {
            throw DataServiceError.invalidData
        }
        
        return data
    }
}

// MARK: - Statistics Extension
extension DataService {
    func getStatistics() async throws -> TestStatistics {
        let results = try await loadTestResults()
        return TestStatistics(from: results)
    }
}

// MARK: - Test Statistics
struct TestStatistics {
    let totalTests: Int
    let averageTime: TimeInterval
    let bestTime: TimeInterval?
    let worstTime: TimeInterval?
    let recentAverage: TimeInterval? // Last 10 tests
    let improvementTrend: Double // Percentage improvement
    
    init(from results: [TestResult]) {
        totalTests = results.count
        
        guard !results.isEmpty else {
            averageTime = 0
            bestTime = nil
            worstTime = nil
            recentAverage = nil
            improvementTrend = 0
            return
        }
        
        let times = results.map { $0.completionTime }
        averageTime = times.reduce(0, +) / Double(times.count)
        bestTime = times.min()
        worstTime = times.max()
        
        // Recent average (last 10 tests)
        if results.count >= 10 {
            let recentTimes = Array(times.prefix(10))
            recentAverage = recentTimes.reduce(0, +) / Double(recentTimes.count)
        } else {
            recentAverage = nil
        }
        
        // Improvement trend calculation
        if results.count >= 20 {
            let firstHalf = Array(times.suffix(10)) // Older tests
            let secondHalf = Array(times.prefix(10)) // Recent tests
            
            let firstAverage = firstHalf.reduce(0, +) / Double(firstHalf.count)
            let secondAverage = secondHalf.reduce(0, +) / Double(secondHalf.count)
            
            improvementTrend = ((firstAverage - secondAverage) / firstAverage) * 100
        } else {
            improvementTrend = 0
        }
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
    
    func deleteTestResult(id: UUID) async throws {
        mockResults.removeAll { $0.id == id }
    }
    
    func clearAllResults() async throws {
        mockResults.removeAll()
    }
    
    func exportResults(format: ExportFormat) async throws -> Data {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        
        switch format {
        case .json:
            return try encoder.encode(mockResults)
        case .csv:
            // Simple CSV implementation for mock
            var csv = "Date,CompletionTime,DeviceType\n"
            for result in mockResults {
                csv += "\(result.formattedDate),\(result.completionTime),\(result.deviceType.rawValue)\n"
            }
            return csv.data(using: .utf8) ?? Data()
        }
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
