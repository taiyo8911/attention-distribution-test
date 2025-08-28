//
//  HistoryViewModel.swift
//  attention-distribution-test
//
//  Created by Taiyo KOSHIBA on 2025/08/18.
//

import Foundation
import SwiftUI

// MARK: - History View Model
@MainActor
class HistoryViewModel: ObservableObject {

    // MARK: - Published Properties
    @Published private(set) var testResults: [TestResult] = []

    // MARK: - Dependencies
    let dataService: DataServiceProtocol

    // MARK: - Initializer
    init(dataService: DataServiceProtocol = DataService()) {
        self.dataService = dataService

        Task {
            await loadTestResults()
        }
    }

    // MARK: - Public Methods
    func loadTestResults() async {
        do {
            let results = try await dataService.loadTestResults()
            testResults = results.sorted { $0.date > $1.date } // 新しい順
            print("Loaded \(results.count) test results")
        } catch {
            print("Failed to load test results: \(error)")
            testResults = []
        }
    }
}

// MARK: - Mock History View Model for Preview
#if DEBUG
class MockHistoryViewModel: HistoryViewModel {
    override init(dataService: DataServiceProtocol = MockDataService()) {
        super.init(dataService: dataService)
    }
}
#endif
