//
//  HistoryViewModel.swift
//  attention-distribution-test
//
//  Created by Taiyo KOSHIBA on 2025/08/18.
//

import Foundation
import Combine
import SwiftUI

// MARK: - History View Model
@MainActor
class HistoryViewModel: ObservableObject {

    // MARK: - Published Properties
    @Published private(set) var testResults: [TestResult] = []
    @Published private(set) var statistics: TestStatistics?
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?
    @Published var showingExportSheet = false
    @Published var showingClearConfirmation = false

    // MARK: - Dependencies
    private let dataService: DataServiceProtocol

    // MARK: - Private Properties
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Computed Properties
    var hasResults: Bool {
        !testResults.isEmpty
    }

    var averageTime: String {
        guard let stats = statistics, stats.totalTests > 0 else { return "--" }
        return stats.averageTime.formattedTime
    }

    var bestTime: String {
        guard let stats = statistics, let best = stats.bestTime else { return "--" }
        return best.formattedTime
    }

    var recentAverage: String {
        guard let stats = statistics, let recent = stats.recentAverage else { return "--" }
        return recent.formattedTime
    }

    var improvementTrend: String {
        guard let stats = statistics, stats.totalTests >= 20 else { return "--" }
        let trend = stats.improvementTrend
        if trend > 0 {
            return "+\(String(format: "%.1f", trend))%"
        } else {
            return "\(String(format: "%.1f", trend))%"
        }
    }

    var improvementColor: Color {
        guard let stats = statistics else { return .secondary }
        if stats.improvementTrend > 0 {
            return .green
        } else if stats.improvementTrend < 0 {
            return .red
        } else {
            return .secondary
        }
    }

    // MARK: - Initializer
    init(dataService: DataServiceProtocol = DataService()) {
        self.dataService = dataService

        Task {
            await loadTestResults()
        }
    }

    // MARK: - Public Methods

    // Data Loading
    func loadTestResults() async {
        isLoading = true
        errorMessage = nil

        do {
            let results = try await dataService.loadTestResults()
            testResults = results
            statistics = TestStatistics(from: results)

            print("Loaded \(results.count) test results")
        } catch {
            errorMessage = "履歴の読み込みに失敗しました: \(error.localizedDescription)"
            print("Failed to load test results: \(error)")
        }

        isLoading = false
    }

    func refresh() async {
        await loadTestResults()
    }

    // Data Management
    func deleteResult(_ result: TestResult) async {
        do {
            try await dataService.deleteTestResult(id: result.id)
            await loadTestResults() // Refresh after deletion

            print("Test result deleted: \(result.id)")
        } catch {
            errorMessage = "結果の削除に失敗しました: \(error.localizedDescription)"
            print("Failed to delete test result: \(error)")
        }
    }

    func clearAllResults() async {
        do {
            try await dataService.clearAllResults()
            testResults = []
            statistics = nil

            print("All test results cleared")
        } catch {
            errorMessage = "履歴のクリアに失敗しました: \(error.localizedDescription)"
            print("Failed to clear all results: \(error)")
        }
    }

    // Export Functionality
    func exportResults(format: ExportFormat) async -> Data? {
        do {
            let data = try await dataService.exportResults(format: format)
            print("Exported \(testResults.count) results as \(format)")
            return data
        } catch {
            errorMessage = "エクスポートに失敗しました: \(error.localizedDescription)"
            print("Failed to export results: \(error)")
            return nil
        }
    }

    // Analysis Methods
    func getPersonalBest() -> TestResult? {
        return testResults.min(by: { $0.completionTime < $1.completionTime })
    }

    func getWorstResult() -> TestResult? {
        return testResults.max(by: { $0.completionTime < $1.completionTime })
    }

    func getResultsFromLastWeek() -> [TestResult] {
        let oneWeekAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        return testResults.filter { $0.date >= oneWeekAgo }
    }

    func getResultsFromLastMonth() -> [TestResult] {
        let oneMonthAgo = Calendar.current.date(byAdding: .month, value: -1, to: Date()) ?? Date()
        return testResults.filter { $0.date >= oneMonthAgo }
    }

    func getRankForResult(_ result: TestResult) -> Int {
        let sortedResults = testResults.sorted { $0.completionTime < $1.completionTime }
        return (sortedResults.firstIndex(of: result) ?? 0) + 1
    }

    // MARK: - Error Handling
    func clearError() {
        errorMessage = nil
    }
}

// MARK: - Chart Data Preparation
extension HistoryViewModel {
    struct ChartDataPoint: Identifiable {
        let id = UUID()
        let date: Date
        let time: TimeInterval
        let isPersonalBest: Bool
    }

    func getChartData(limit: Int = 30) -> [ChartDataPoint] {
        let recentResults = Array(testResults.prefix(limit)).reversed()
        let personalBest = getPersonalBest()

        return recentResults.map { result in
            ChartDataPoint(
                date: result.date,
                time: result.completionTime,
                isPersonalBest: result.id == personalBest?.id
            )
        }
    }

    func getTimeRangeData() -> (min: TimeInterval, max: TimeInterval, average: TimeInterval) {
        guard !testResults.isEmpty else {
            return (0, 0, 0)
        }

        let times = testResults.map { $0.completionTime }
        let min = times.min() ?? 0
        let max = times.max() ?? 0
        let average = times.reduce(0, +) / Double(times.count)

        return (min, max, average)
    }
}

// MARK: - Filtering and Sorting
extension HistoryViewModel {
    enum SortOption: String, CaseIterable {
        case dateNewest = "date_newest"
        case dateOldest = "date_oldest"
        case timeFastest = "time_fastest"
        case timeSlowest = "time_slowest"

        var displayName: String {
            switch self {
            case .dateNewest: return "新しい順"
            case .dateOldest: return "古い順"
            case .timeFastest: return "速い順"
            case .timeSlowest: return "遅い順"
            }
        }
    }

    enum FilterOption: String, CaseIterable {
        case all = "all"
        case lastWeek = "last_week"
        case lastMonth = "last_month"
        case iPhone = "iphone"
        case iPad = "ipad"

        var displayName: String {
            switch self {
            case .all: return "すべて"
            case .lastWeek: return "過去1週間"
            case .lastMonth: return "過去1ヶ月"
            case .iPhone: return "iPhone"
            case .iPad: return "iPad"
            }
        }
    }

    func getSortedAndFilteredResults(
        sortBy: SortOption = .dateNewest,
        filterBy: FilterOption = .all
    ) -> [TestResult] {
        var results = testResults

        // Apply filter
        switch filterBy {
        case .all:
            break
        case .lastWeek:
            results = getResultsFromLastWeek()
        case .lastMonth:
            results = getResultsFromLastMonth()
        case .iPhone:
            results = results.filter { $0.deviceType == .iPhone }
        case .iPad:
            results = results.filter { $0.deviceType == .iPad }
        }

        // Apply sort
        switch sortBy {
        case .dateNewest:
            results.sort { $0.date > $1.date }
        case .dateOldest:
            results.sort { $0.date < $1.date }
        case .timeFastest:
            results.sort { $0.completionTime < $1.completionTime }
        case .timeSlowest:
            results.sort { $0.completionTime > $1.completionTime }
        }

        return results
    }
}

// MARK: - Mock History View Model
#if DEBUG
class MockHistoryViewModel: HistoryViewModel {
    override init(dataService: DataServiceProtocol = MockDataService()) {
        super.init(dataService: dataService)
    }
}
#endif
