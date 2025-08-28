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

    // MARK: - Test Timing
    private var testStartTime: Date?

    // MARK: - Dependencies
    private let timerService: TimerServiceProtocol
    private let dataService: DataServiceProtocol
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Computed Properties
    var gameState: GameState { testModel.gameState }
    var currentNumber: Int { testModel.currentNumber }
    var showError: Bool { testModel.showError }

    // canConfirmをViewModelで管理
    var canConfirm: Bool {
        testModel.selectedPosition != nil && !testModel.showError && gameState == .inProgress
    }

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
    func startTest() {
        testStartTime = Date()
        testModel.startTest()
        timerService.start()
    }

    func resetTest() {
        timerService.reset()
        testModel.resetTest()
        elapsedTime = 0
        testStartTime = nil
    }

    func tapNumber(at row: Int, col: Int) {
        // 数字をタップした時は選択状態のみ設定
        let success = testModel.tapNumber(at: row, col: col)
        let tappedNumber = testModel.getNumber(at: row, col: col)
        print("Tapped (\(row),\(col)): \(tappedNumber), Selected: \(success)")
    }

    func confirmSelectionWithResult() -> Bool {
        let completed = testModel.confirmSelection()

        if testModel.showError {
            // 不正解の場合
            print("Incorrect selection.")
            return false
        } else if completed {
            // 完了の場合
            timerService.stop()

            Task {
                await saveTestResult()
            }

            return true
        } else {
            // 正解で次へ進む場合
            print("Correct! Moving to next number: \(testModel.currentNumber)")
            return false
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
        guard let startTime = testStartTime else { return }

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
