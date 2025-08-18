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

    var canConfirm: Bool {
        return selectedPosition != nil && !showError
    }

    // MARK: - Initializer
    init() {
        // 初期化時は空配列
        gridNumbers = []
    }

    // MARK: - Grid Management
    mutating func generateGrid() {
        // 7x7グリッドを初期化
        gridNumbers = Array(repeating: Array(repeating: 0, count: gridSize), count: gridSize)

        // 中央(3,3)に0を配置
        gridNumbers[3][3] = 0

        // 1から48までの数字をシャッフル
        var numbers = Array(1...48)
        numbers.shuffle()

        // 中央以外の位置に数字を配置
        var index = 0
        for row in 0..<7 {
            for col in 0..<7 {
                if row != 3 || col != 3 { // 中央以外
                    gridNumbers[row][col] = numbers[index]
                    index += 1
                }
            }
        }
    }

    func getNumber(at row: Int, col: Int) -> Int {
        guard row >= 0, row < 7, col >= 0, col < 7,
              !gridNumbers.isEmpty,
              row < gridNumbers.count,
              col < gridNumbers[row].count else {
            return -1
        }
        return gridNumbers[row][col]
    }

    // MARK: - Game State Management
    mutating func startTest() {
        gameState = .inProgress
        startTime = Date()
        generateGrid()
        currentNumber = 0
        selectedPosition = nil
        showError = false
        tapHistory.removeAll()
    }

    mutating func resetTest() {
        gameState = .notStarted
        currentNumber = 0
        selectedPosition = nil
        showError = false
        startTime = nil
        endTime = nil
        gridNumbers = []
        tapHistory.removeAll()
    }

    mutating func completeTest() {
        gameState = .completed
        endTime = Date()
    }

    // MARK: - User Interaction
    mutating func tapNumber(at row: Int, col: Int) -> Bool {
        guard gameState == .inProgress else { return false }

        let tappedNumber = getNumber(at: row, col: col)

        if tappedNumber == currentNumber {
            // 正解
            selectedPosition = GridPosition(row: row, col: col)
            showError = false
            return true
        } else {
            // 不正解
            selectedPosition = nil
            showError = true
            return false
        }
    }

    mutating func confirmSelection() -> Bool {
        guard canConfirm else { return false }

        currentNumber += 1
        selectedPosition = nil
        showError = false

        if currentNumber > targetNumber {
            completeTest()
            return true
        }
        return false
    }
}

// MARK: - Supporting Types
struct GridPosition: Equatable {
    let row: Int
    let col: Int
}

struct TapRecord {
    let number: Int
    let position: GridPosition
    let timestamp: Date
    let isCorrect: Bool
}
