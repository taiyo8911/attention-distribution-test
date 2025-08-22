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
        // 何かが選択されていて、エラー状態でない場合に確認可能
        return selectedPosition != nil && !showError && gameState == .inProgress
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

        // 数字をタップした時は選択状態のみ設定（正誤判定はしない）
        selectedPosition = GridPosition(row: row, col: col)
        lastTappedPosition = GridPosition(row: row, col: col)

        // エラー状態をクリア（新しい選択をした場合）
        showError = false
        errorMessage = ""

        return true
    }

    mutating func confirmSelection() -> Bool {
        guard let position = selectedPosition else { return false }
        guard gameState == .inProgress else { return false }

        let selectedNumber = getNumber(at: position.row, col: position.col)

        // タップ履歴に記録
        let tapRecord = TapRecord(
            number: selectedNumber,
            position: position,
            timestamp: Date(),
            isCorrect: selectedNumber == currentNumber
        )
        tapHistory.append(tapRecord)

        if selectedNumber == currentNumber {
            // 正解の場合
            currentNumber += 1
            selectedPosition = nil
            showError = false
            errorMessage = ""

            // 完了チェック
            if currentNumber > targetNumber {
                completeTest()
                return true
            }
            return false
        } else {
            // 不正解の場合
            showError = true
            errorMessage = "正しい数字をタップしてください。"
            selectedPosition = nil // 選択状態をリセット
            return false
        }
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
