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

    // MARK: - Private Properties
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Computed Properties
    var gameState: GameState { testModel.gameState }
    var currentNumber: Int { testModel.currentNumber }
    var gridNumbers: [[Int]] { testModel.gridNumbers }
    var selectedPosition: GridPosition? { testModel.selectedPosition }
    var showError: Bool { testModel.showError }
    var errorMessage: String { testModel.errorMessage }
    var canConfirm: Bool { testModel.canConfirm }
    var isComplete: Bool { testModel.isComplete }

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
        testModel.updateGameState(.inProgress)
        timerService.start()
    }

    func stopTest() {
        testModel.updateGameState(.cancelled)
        timerService.stop()
    }

    func resetTest() {
        testModel.updateGameState(.notStarted)
        timerService.reset()
        elapsedTime = 0
        showingResultView = false
    }

    func tapNumber(at row: Int, col: Int) {
        guard gameState.shouldAcceptInput else { return }

        let position = GridPosition(row: row, col: col)
        let _ = testModel.tapNumber(at: position)
    }

    func confirmSelection() {
        guard canConfirm else { return }

        let wasCompleted = testModel.confirmSelection()

        if wasCompleted {
            completeTest()
        }
    }

    func startCountdown() {
        testModel.updateGameState(.countdown)
    }

    func completeCountdown() {
        startTest()
    }

    // MARK: - Grid Helper Methods
    func getNumber(at row: Int, col: Int) -> Int {
        guard row >= 0, row < testModel.gridSize,
              col >= 0, col < testModel.gridSize,
              !testModel.gridNumbers.isEmpty,
              row < testModel.gridNumbers.count,
              col < testModel.gridNumbers[row].count else {
            return -1
        }
        return testModel.gridNumbers[row][col]
    }

    func isSelected(row: Int, col: Int) -> Bool {
        guard let selectedPos = testModel.selectedPosition,
              row >= 0, row < testModel.gridSize,
              col >= 0, col < testModel.gridSize else {
            return false
        }
        return selectedPos.row == row && selectedPos.col == col
    }

    // MARK: - Private Methods
    private func completeTest() {
        timerService.stop()

        Task {
            await saveTestResult()
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.showingResultView = true
        }
    }

    private func saveTestResult() async {
        guard let startTime = testModel.startTime,
              let endTime = testModel.endTime else { return }

        let result = TestResult(
            startTime: startTime,
            endTime: endTime,
            completionTime: elapsedTime
        )

        do {
            try await dataService.saveTestResult(result)
            print("Test result saved successfully")
        } catch {
            print("Failed to save test result: \(error)")
        }
    }

    private func setupTimerObservation() {
        timerService.elapsedTimePublisher
            .receive(on: DispatchQueue.main)
            .assign(to: \.elapsedTime, on: self)
            .store(in: &cancellables)
    }
}
