//
//  TestView.swift
//  attention-distribution-test
//
//  Created by Taiyo KOSHIBA on 2025/08/18.
//

import SwiftUI

struct TestView: View {
    @EnvironmentObject var testViewModel: TestViewModel
    @State private var showingStopConfirmation = false
    @Environment(\.dismiss) var dismiss

    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                // Header section
                headerSection

                // Main grid content
                mainContentSection(geometry: geometry)

                // Footer section
                footerSection
            }
        }
        .navigationBarHidden(true)
        .background(Color(.systemBackground))
        .onChange(of: testViewModel.isComplete) { isComplete in
            if isComplete {
                // Test completed, navigation will be handled by ResultView presentation
            }
        }
        .fullScreenCover(isPresented: $testViewModel.showingResultView) {
            ResultView()
                .environmentObject(testViewModel)
        }
        .alert("検査を中断しますか？", isPresented: $showingStopConfirmation) {
            Button("中断する", role: .destructive) {
                testViewModel.stopTest()
                dismiss()
            }
            Button("続ける", role: .cancel) { }
        } message: {
            Text("中断すると現在の検査データは保存されません。")
        }
    }

    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: 12) {
            // Top status bar
            HStack {
                // Progress indicator
                progressIndicator

                Spacer()

                // Stop button
                stopButton
            }

            // Timer display (MM:SS format)
            TimerView(
                elapsedTime: testViewModel.elapsedTime,
                gameState: testViewModel.gameState,
                style: .prominent,
                showMilliseconds: false // Changed to false for MM:SS format
            )

            // Current target display
            currentTargetDisplay

            // Error message
            if testViewModel.showError {
                errorMessageView
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(Color(.systemBackground))
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }

    private var progressIndicator: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("進捗")
                .font(.caption)
                .foregroundColor(.secondary)

            HStack(spacing: 8) {
                ProgressView(value: testViewModel.progress)
                    .tint(.blue)
                    .frame(width: 80)

                Text("\(testViewModel.currentNumber)/48")
                    .font(.caption)
                    .fontWeight(.medium)
                    .monospacedDigit()
            }
        }
    }

    private var stopButton: some View {
        Button(action: {
            showingStopConfirmation = true
        }) {
            HStack(spacing: 6) {
                Image(systemName: "stop.circle")
                Text("中断")
            }
            .font(.callout)
            .foregroundColor(.red)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color.red.opacity(0.1))
            .cornerRadius(8)
        }
    }

    private var currentTargetDisplay: some View {
        VStack(spacing: 8) {
            Text("次に押す数字")
                .font(.callout)
                .foregroundColor(.secondary)

            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(Color.blue.opacity(0.1))
                        .frame(width: 50, height: 50)

                    Text("\(testViewModel.currentNumber)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                }

                // Location hint
                if let position = testViewModel.findPosition(of: testViewModel.currentNumber) {
                    VStack(spacing: 2) {
                        Text("位置")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        Text("(\(position.row + 1), \(position.col + 1))")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.blue)
                    }
                }
            }
        }
        .padding(.vertical, 8)
    }

    private var errorMessageView: some View {
        HStack {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(.red)

            VStack(alignment: .leading, spacing: 2) {
                Text("⚠️ 間違いです")
                    .font(.callout)
                    .fontWeight(.semibold)
                    .foregroundColor(.red)

                Text("正しい数字をタップしてください")
                    .font(.caption)
                    .foregroundColor(.red)
            }

            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color.red.opacity(0.1))
        .cornerRadius(10)
        .transition(.asymmetric(
            insertion: .move(edge: .top).combined(with: .opacity),
            removal: .move(edge: .top).combined(with: .opacity)
        ))
        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: testViewModel.showError)
    }

    // MARK: - Main Content Section
    private func mainContentSection(geometry: GeometryProxy) -> some View {
        let safeArea = geometry.safeAreaInsets
        let headerHeight: CGFloat = 200
        let footerHeight: CGFloat = 100
        let availableHeight = geometry.size.height - headerHeight - footerHeight - safeArea.top - safeArea.bottom
        let availableWidth = geometry.size.width - 32
        let gridSize = min(availableWidth, availableHeight)
        let cellSize = gridSize / 7

        return VStack {
            Spacer()

            // 7x7 Grid
            LazyVGrid(columns: Array(repeating: GridItem(.fixed(cellSize), spacing: 1), count: 7), spacing: 1) {
                ForEach(0..<7, id: \.self) { row in
                    ForEach(0..<7, id: \.self) { col in
                        GridCell(
                            number: testViewModel.getNumber(at: row, col: col),
                            isSelected: testViewModel.isSelected(row: row, col: col),
                            cellSize: cellSize,
                            isCurrentTarget: testViewModel.getNumber(at: row, col: col) == testViewModel.currentNumber,
                            animationDelay: Double(row * 7 + col) * 0.01
                        ) {
                            testViewModel.tapNumber(at: row, col: col)
                        }
                    }
                }
            }
            .background(Color.black)
            .cornerRadius(8)
            .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)

            Spacer()
        }
        .padding(.horizontal, 16)
    }

    // MARK: - Footer Section
    private var footerSection: some View {
        VStack(spacing: 16) {
            // Confirmation button
            Button(action: {
                testViewModel.confirmSelection()
            }) {
                HStack {
                    if testViewModel.canConfirm {
                        Image(systemName: "checkmark.circle.fill")
                    } else {
                        Image(systemName: "hand.tap")
                    }

                    Text(confirmButtonTitle)
                }
                .font(.title3)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(confirmButtonColor)
                .cornerRadius(12)
            }
            .disabled(!testViewModel.canConfirm)
            .scaleEffect(testViewModel.canConfirm ? 1.0 : 0.95)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: testViewModel.canConfirm)

            // Quick stats
            quickStatsView
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 20)
    }

    private var confirmButtonTitle: String {
        if testViewModel.canConfirm {
            return "確認"
        } else if testViewModel.selectedPosition != nil {
            return "処理中..."
        } else {
            return "数字をタップしてください"
        }
    }

    private var confirmButtonColor: Color {
        if testViewModel.canConfirm {
            return .blue
        } else {
            return .gray
        }
    }

    private var quickStatsView: some View {
        HStack {
            // Remaining numbers
            VStack(spacing: 2) {
                Text("残り")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text("\(48 - testViewModel.currentNumber + 1)")
                    .font(.callout)
                    .fontWeight(.semibold)
                    .monospacedDigit()
            }

            Spacer()

            // Current pace (numbers per minute)
            VStack(spacing: 2) {
                Text("ペース")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(currentPaceText)
                    .font(.caption)
                    .fontWeight(.medium)
                    .monospacedDigit()
            }

            Spacer()

            // Estimated completion time (MM:SS format)
            VStack(spacing: 2) {
                Text("予想完了")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(estimatedCompletionText)
                    .font(.caption)
                    .fontWeight(.medium)
                    .monospacedDigit()
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(10)
    }

    // MARK: - Computed Properties
    private var currentPaceText: String {
        guard testViewModel.elapsedTime > 0 && testViewModel.currentNumber > 0 else {
            return "--"
        }

        let numbersPerSecond = Double(testViewModel.currentNumber) / testViewModel.elapsedTime
        let numbersPerMinute = numbersPerSecond * 60
        return String(format: "%.1f/分", numbersPerMinute)
    }

    private var estimatedCompletionText: String {
        guard testViewModel.elapsedTime > 0 && testViewModel.currentNumber > 0 else {
            return "--"
        }

        let averageTimePerNumber = testViewModel.elapsedTime / Double(testViewModel.currentNumber)
        let remainingNumbers = 48 - testViewModel.currentNumber + 1
        let estimatedRemainingTime = averageTimePerNumber * Double(remainingNumbers)
        let estimatedTotalTime = testViewModel.elapsedTime + estimatedRemainingTime

        // Use MM:SS format instead of shortFormattedTime
        return estimatedTotalTime.formattedTime
    }
}

#Preview {
    let testViewModel = TestViewModel(
        timerService: MockTimerService(),
        dataService: MockDataService()
    )
    testViewModel.startTest() // Start test for preview

    return TestView()
        .environmentObject(testViewModel)
}
