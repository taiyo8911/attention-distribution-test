//
//  TestViewModel.swift
//  attention-distribution-test
//
//  Created by Taiyo KOSHIBA on 2025/08/18.
//


import Foundation
import Combine
import SwiftUI

// MARK: - Test View Model
@MainActor
class TestViewModel: ObservableObject {
    
    // MARK: - Published Properties
    @Published private(set) var testModel = TestModel()
    @Published private(set) var elapsedTime: TimeInterval = 0
    @Published var showingStopConfirmation = false
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
    var progress: Double { testModel.progress }
    
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
    
    // Game State Management
    func startTest() {
        testModel.updateGameState(.inProgress)
        timerService.start()
    }
    
    func pauseTest() {
        testModel.updateGameState(.paused)
        timerService.pause()
    }
    
    func resumeTest() {
        testModel.updateGameState(.inProgress)
        timerService.resume()
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
    
    // User Interaction
    func tapNumber(at row: Int, col: Int) {
        guard gameState.shouldAcceptInput else { return }
        
        let position = GridPosition(row: row, col: col)
        let _ = testModel.tapNumber(at: position)
        
        // Add haptic feedback
        if testModel.showError {
            let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
            impactFeedback.impactOccurred()
        } else {
            let impactFeedback = UIImpactFeedbackGenerator(style: .light)
            impactFeedback.impactOccurred()
        }
    }
    
    func confirmSelection() {
        guard canConfirm else { return }
        
        let wasCompleted = testModel.confirmSelection()
        
        if wasCompleted {
            completeTest()
        }
        
        // Add haptic feedback for confirmation
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
    }
    
    // Test Completion
    private func completeTest() {
        timerService.stop()
        
        Task {
            await saveTestResult()
        }
        
        // Show completion haptic
        let notificationFeedback = UINotificationFeedbackGenerator()
        notificationFeedback.notificationOccurred(.success)
        
        // Delay before showing result view
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.showingResultView = true
        }
    }
    
    // Data Management
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
            // Could show an error alert here
        }
    }
    
    // MARK: - Private Methods
    private func setupTimerObservation() {
        timerService.elapsedTimePublisher
            .receive(on: DispatchQueue.main)
            .assign(to: \.elapsedTime, on: self)
            .store(in: &cancellables)
    }
}

// MARK: - Grid Helper Methods
extension TestViewModel {
    func getNumber(at row: Int, col: Int) -> Int {
        guard row >= 0, row < testModel.gridSize,
              col >= 0, col < testModel.gridSize else { return -1 }
        return testModel.gridNumbers[row][col]
    }
    
    func isSelected(row: Int, col: Int) -> Bool {
        guard let selectedPos = testModel.selectedPosition else { return false }
        return selectedPos.row == row && selectedPos.col == col
    }
    
    func findPosition(of number: Int) -> GridPosition? {
        return testModel.findPosition(of: number)
    }
}

// MARK: - Countdown Management
extension TestViewModel {
    func startCountdown() {
        testModel.updateGameState(.countdown)
    }
    
    func completeCountdown() {
        startTest()
    }
}

// MARK: - Error Handling
extension TestViewModel {
    func clearError() {
        // Error clearing is handled internally by the model
        // This method is available for manual error clearing if needed
    }
}

// MARK: - Debug Methods
#if DEBUG
extension TestViewModel {
    func debugCompleteTest() {
        // Force complete test for debugging purposes
        testModel.updateGameState(.completed)
        timerService.stop()
        showingResultView = true
    }
    
    func debugSetCurrentNumber(_ number: Int) {
        // Force set current number for debugging
        // This bypasses normal game logic
    }
    
    func debugPrintState() {
        print("=== Test State Debug ===")
        print("Game State: \(gameState)")
        print("Current Number: \(currentNumber)")
        print("Elapsed Time: \(elapsedTime)")
        print("Timer Running: \(timerService.isRunning)")
        print("Can Confirm: \(canConfirm)")
        print("Show Error: \(showError)")
        if showError {
            print("Error Message: \(errorMessage)")
        }
        print("=======================")
    }
}
#endif
