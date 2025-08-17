//
//  ContentView.swift
//  attention-distribution-test
//
//  Created by Taiyo KOSHIBA on 2025/08/18.
//

import SwiftUI

// MARK: - Data Models
struct TestResult {
    let date: Date
    let completionTime: TimeInterval
    let deviceType: String
}

// MARK: - Main Content View
struct ContentView: View {
    @StateObject private var testManager = TestManager()

    var body: some View {
        NavigationView {
            StartView()
                .environmentObject(testManager)
        }
        .navigationViewStyle(StackNavigationViewStyle()) // iPhone/iPad対応
    }
}

// MARK: - Test Manager (状態管理)
class TestManager: ObservableObject {
    @Published var currentNumber = 0
    @Published var isTestRunning = false
    @Published var startTime: Date?
    @Published var elapsedTime: TimeInterval = 0
    @Published var gridNumbers: [[Int]] = Array(repeating: Array(repeating: -1, count: 7), count: 7)
    @Published var selectedPosition: (Int, Int)?
    @Published var showError = false
    @Published var testResults: [TestResult] = []

    private var timer: Timer?

    init() {
        loadTestHistory()
    }

    // MARK: - Test Control
    func startTest() {
        resetTest()
        generateGrid()
        isTestRunning = true
        startTime = Date()
        startTimer()
    }

    func resetTest() {
        currentNumber = 0
        elapsedTime = 0
        selectedPosition = nil
        showError = false
        stopTimer()
    }

    func stopTest() {
        isTestRunning = false
        stopTimer()
    }

    func completeTest() {
        guard let startTime = startTime else { return }
        let completionTime = Date().timeIntervalSince(startTime)

        let result = TestResult(
            date: Date(),
            completionTime: completionTime,
            deviceType: UIDevice.current.userInterfaceIdiom == .pad ? "iPad" : "iPhone"
        )

        testResults.insert(result, at: 0)
        if testResults.count > 100 {
            testResults = Array(testResults.prefix(100))
        }

        saveTestHistory()
        stopTest()
    }

    // MARK: - Grid Generation
    private func generateGrid() {
        // 7x7グリッドを初期化
        gridNumbers = Array(repeating: Array(repeating: -1, count: 7), count: 7)

        // 中央に0を配置
        gridNumbers[3][3] = 0

        // 1-48の数字をランダムに配置
        var numbers = Array(1...48)
        numbers.shuffle()

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

    // MARK: - Number Selection
    func selectNumber(at row: Int, col: Int) -> Bool {
        let selectedNumber = gridNumbers[row][col]

        if selectedNumber == currentNumber {
            selectedPosition = (row, col)
            showError = false
            return true
        } else {
            showError = true
            selectedPosition = nil
            return false
        }
    }

    func confirmSelection() {
        guard selectedPosition != nil else { return }

        currentNumber += 1
        selectedPosition = nil
        showError = false

        if currentNumber > 48 {
            completeTest()
        }
    }

    // MARK: - Timer
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { _ in
            guard let startTime = self.startTime else { return }
            self.elapsedTime = Date().timeIntervalSince(startTime)
        }
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    // MARK: - Data Persistence
    private func saveTestHistory() {
        let encoder = JSONEncoder()
        if let data = try? encoder.encode(testResults) {
            UserDefaults.standard.set(data, forKey: "TestHistory")
        }
    }

    private func loadTestHistory() {
        guard let data = UserDefaults.standard.data(forKey: "TestHistory") else { return }
        let decoder = JSONDecoder()
        if let results = try? decoder.decode([TestResult].self, from: data) {
            testResults = results
        }
    }
}

// MARK: - TestResult Codable Extension
extension TestResult: Codable {}

// MARK: - Time Formatting Extension
extension TimeInterval {
    var formattedTime: String {
        let minutes = Int(self) / 60
        let seconds = Int(self) % 60
        let milliseconds = Int((self.truncatingRemainder(dividingBy: 1)) * 100)
        return String(format: "%02d:%02d:%02d", minutes, seconds, milliseconds)
    }
}

#Preview {
    ContentView()
}
