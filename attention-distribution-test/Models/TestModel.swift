//
//  TestModel.swift
//  attention-distribution-test
//
//  Created by Taiyo KOSHIBA on 2025/08/18.
//

import Foundation

// MARK: - Test Model
struct TestModel {
    // MARK: - Game Progress
    private(set) var gameState: GameState = .notStarted
    private(set) var currentNumber: Int = 0
    private(set) var targetNumber: Int = 48

    // MARK: - Grid Configuration
    private(set) var gridSize: Int = 7
    private(set) var gridNumbers: [[Int]] = []

    // MARK: - User Interaction
    private(set) var selectedPosition: GridPosition?
    private(set) var lastTappedPosition: GridPosition?
    private(set) var showError: Bool = false
    private(set) var errorMessage: String = ""

    // MARK: - Timing
    private(set) var startTime: Date?
    private(set) var endTime: Date?
    private(set) var pauseStartTime: Date?
    private(set) var totalPauseTime: TimeInterval = 0

    // MARK: - History
    private(set) var tapHistory: [TapRecord] = []

    // MARK: - Computed Properties
    var isComplete: Bool {
        return currentNumber > targetNumber
    }

    var progress: Double {
        return Double(currentNumber) / Double(targetNumber + 1)
    }

    var elapsedTime: TimeInterval {
        guard let startTime = startTime else { return 0 }

        let endPoint = endTime ?? Date()
        let totalTime = endPoint.timeIntervalSince(startTime)

        // 一時停止時間を除く
        var pauseTime = totalPauseTime
        if gameState == .paused, let pauseStart = pauseStartTime {
            pauseTime += Date().timeIntervalSince(pauseStart)
        }

        return max(0, totalTime - pauseTime)
    }

    var canConfirm: Bool {
        return selectedPosition != nil && !showError
    }

    // MARK: - Initializer
    init() {
        // 初期化時は空の配列のまま（generateGrid()でのみ数字を配置）
        gridNumbers = []
    }
}

// MARK: - Game State Management
extension TestModel {
    mutating func updateGameState(_ newState: GameState) {
        guard gameState.canTransition(to: newState) else {
            print("Invalid state transition from \(gameState) to \(newState)")
            return
        }

        let oldState = gameState
        gameState = newState

        // State-specific actions
        switch newState {
        case .inProgress:
            if oldState == .countdown {
                startTest()
            } else if oldState == .paused {
                resumeTest()
            }
        case .paused:
            pauseTest()
        case .completed:
            completeTest()
        case .cancelled:
            cancelTest()
        case .notStarted:
            reset()
        default:
            break
        }
    }

    private mutating func startTest() {
        startTime = Date()
        generateGrid()
        clearError()
        tapHistory.removeAll()
        totalPauseTime = 0
    }

    private mutating func pauseTest() {
        pauseStartTime = Date()
    }

    private mutating func resumeTest() {
        if let pauseStart = pauseStartTime {
            totalPauseTime += Date().timeIntervalSince(pauseStart)
            pauseStartTime = nil
        }
    }

    private mutating func completeTest() {
        endTime = Date()
        if let pauseStart = pauseStartTime {
            totalPauseTime += Date().timeIntervalSince(pauseStart)
            pauseStartTime = nil
        }
    }

    private mutating func cancelTest() {
        endTime = Date()
    }

    mutating func reset() {
        gameState = .notStarted
        currentNumber = 0
        selectedPosition = nil
        lastTappedPosition = nil
        showError = false
        errorMessage = ""
        startTime = nil
        endTime = nil
        pauseStartTime = nil
        totalPauseTime = 0
        tapHistory.removeAll()
        gridNumbers = [] // リセット時は空配列に戻す
    }
}

// MARK: - Grid Management
extension TestModel {
    mutating func generateGrid() {
        // 7x7グリッドを初期化
        gridNumbers = Array(repeating: Array(repeating: -1, count: gridSize), count: gridSize)

        // 中央に0を配置
        let centerPos = gridSize / 2
        gridNumbers[centerPos][centerPos] = 0

        // 1からtargetNumberまでの数字をランダムに配置
        var numbers = Array(1...targetNumber)
        numbers.shuffle()

        var index = 0
        for row in 0..<gridSize {
            for col in 0..<gridSize {
                if row != centerPos || col != centerPos { // 中央以外
                    if index < numbers.count {
                        gridNumbers[row][col] = numbers[index]
                        index += 1
                    }
                }
            }
        }
    }

    func getNumber(at position: GridPosition) -> Int? {
        guard position.isValid(for: gridSize),
              !gridNumbers.isEmpty,
              position.row < gridNumbers.count,
              position.col < gridNumbers[position.row].count else {
            return nil
        }
        return gridNumbers[position.row][position.col]
    }

    func findPosition(of number: Int) -> GridPosition? {
        guard !gridNumbers.isEmpty else { return nil }

        for row in 0..<gridSize {
            for col in 0..<gridSize {
                if row < gridNumbers.count && col < gridNumbers[row].count {
                    if gridNumbers[row][col] == number {
                        return GridPosition(row: row, col: col)
                    }
                }
            }
        }
        return nil
    }
}

// MARK: - User Interaction
extension TestModel {
    mutating func tapNumber(at position: GridPosition) -> Bool {
        guard gameState.shouldAcceptInput else { return false }
        guard position.isValid(for: gridSize) else { return false }
        guard !gridNumbers.isEmpty,
              position.row < gridNumbers.count,
              position.col < gridNumbers[position.row].count else {
            return false
        }

        let tappedNumber = gridNumbers[position.row][position.col]
        lastTappedPosition = position

        // タップ履歴を記録
        let tapRecord = TapRecord(
            number: tappedNumber,
            position: position,
            timestamp: Date(),
            isCorrect: tappedNumber == currentNumber
        )
        tapHistory.append(tapRecord)

        if tappedNumber == currentNumber {
            // 正解
            selectedPosition = position
            clearError()
            return true
        } else {
            // 不正解
            selectedPosition = nil
            showError(message: "⚠️ 間違いです。正しい数字をタップしてください。")
            return false
        }
    }

    mutating func confirmSelection() -> Bool {
        guard canConfirm else { return false }
        guard selectedPosition != nil else { return false }

        currentNumber += 1
        selectedPosition = nil
        clearError()

        if currentNumber > targetNumber {
            updateGameState(.completed)
        }

        return true
    }

    private mutating func showError(message: String) {
        showError = true
        errorMessage = message
    }

    private mutating func clearError() {
        showError = false
        errorMessage = ""
    }
}

// MARK: - Supporting Types
struct GridPosition: Equatable, Codable {
    let row: Int
    let col: Int

    func isValid(for gridSize: Int) -> Bool {
        return row >= 0 && row < gridSize && col >= 0 && col < gridSize
    }
}

struct TapRecord: Codable {
    let number: Int
    let position: GridPosition
    let timestamp: Date
    let isCorrect: Bool

    var elapsedTime: TimeInterval {
        // This would be calculated relative to test start time
        // Implementation depends on context
        return 0
    }
}
