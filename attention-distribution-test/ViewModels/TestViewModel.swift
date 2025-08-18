//
//  TestViewModel.swift
//  attention-distribution-test
//
//  Created by Taiyo KOSHIBA on 2025/08/18.
//

import Foundation
import Combine
import SwiftUI

@MainActor
class TestViewModel: ObservableObject {

    // MARK: - Published Properties
    @Published private(set) var testModel = TestModel()
    @Published private(set) var elapsedTime: TimeInterval = 0
    @Published var showingResultView = false

    // MARK: - Dependencies
    private let timerService: TimerServiceProtocol
    private let dataService: DataServiceProtocol
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Computed Properties
    var gameState: GameState { testModel.gameState }
    var currentNumber: Int { testModel.currentNumber }
    var showError: Bool { testModel.showError }
    var canConfirm: Bool { testModel.canConfirm }

    // MARK: - Initializer
    init(
        timerService: TimerServiceProtocol = TimerService(),
        dataService: DataServiceProtocol = DataService()
    ) {
        self.timerService = timerService
        self.dataService = dataService
        setupTimerObservation()
    }

    // MARK: - Public Methods
    func startCountdown() {
        // カウントダウン開始
    }

    func startTest() {
        testModel.startTest()
        timerService.start()
    }

    func stopTest() {
        timerService.stop()
        testModel.resetTest()
    }

    func resetTest() {
        timerService.reset()
        testModel.resetTest()
        elapsedTime = 0
        showingResultView = false
    }

    func tapNumber(at row: Int, col: Int) {
        let success = testModel.tapNumber(at: row, col: col)
        print("Tapped (\(row),\(col)): \(testModel.getNumber(at: row, col: col)), Success: \(success)")
    }

    func confirmSelection() {
        let completed = testModel.confirmSelection()
        if completed {
            timerService.stop()

            Task {
                await saveTestResult()
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.showingResultView = true
            }
        }
    }

    // MARK: - Grid Helper Methods
    func getNumber(at row: Int, col: Int) -> Int {
        return testModel.getNumber(at: row, col: col)
    }

    func isSelected(row: Int, col: Int) -> Bool {
        guard let selectedPos = testModel.selectedPosition else { return false }
        return selectedPos.row == row && selectedPos.col == col
    }

    // MARK: - Private Methods
    private func saveTestResult() async {
        guard let startTime = testModel.startTime else { return }

        let result = TestResult(
            startTime: startTime,
            endTime: Date(),
            completionTime: elapsedTime
        )

        do {
            try await dataService.saveTestResult(result)
        } catch {
            print("Failed to save result: \(error)")
        }
    }

    private func setupTimerObservation() {
        timerService.elapsedTimePublisher
            .receive(on: DispatchQueue.main)
            .assign(to: \.elapsedTime, on: self)
            .store(in: &cancellables)
    }
}
