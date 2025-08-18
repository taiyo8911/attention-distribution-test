//
//  StartView.swift
//  attention-distribution-test
//
//  Created by Taiyo KOSHIBA on 2025/08/18.
//

import SwiftUI

struct StartView: View {
    @EnvironmentObject var testViewModel: TestViewModel
    @EnvironmentObject var historyViewModel: HistoryViewModel

    @State private var showingConfirmation = false
    @State private var showingHistory = false
    @State private var showingCountdown = false
    @State private var showingSettings = false

    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                headerSection

                Spacer()

                mainContent

                Spacer()

                buttonSection

                Spacer()

                if historyViewModel.hasResults {
                    quickStatsSection
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(backgroundGradient)
        }
        .navigationTitle("")
        .navigationBarHidden(true)
        .alert("検査を開始しますか？", isPresented: $showingConfirmation) {
            Button("YES") {
                startTest()
            }
            Button("NO", role: .cancel) {
                showingConfirmation = false
            }
        } message: {
            Text("0から48まで順番に数字をタップする検査です。\n集中して取り組んでください。")
        }
        .sheet(isPresented: $showingHistory) {
            HistoryView()
                .environmentObject(historyViewModel)
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView()
        }
        .fullScreenCover(isPresented: $showingCountdown) {
            CountdownView()
                .environmentObject(testViewModel)
        }
        .onAppear {
            Task {
                await historyViewModel.refresh()
            }
        }
    }

    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: 16) {
            // App icon area
            ZStack {
                Circle()
                    .fill(LinearGradient(
                        gradient: Gradient(colors: [.blue.opacity(0.1), .blue.opacity(0.3)]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .frame(width: 100, height: 100)

                Image(systemName: "brain.head.profile")
                    .font(.system(size: 40, weight: .medium))
                    .foregroundColor(.blue)
            }

            // App title
            VStack(spacing: 8) {
                Text("注意配分検査")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)

                Text("運転適正検査")
                    .font(.title2)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.top, 60)
    }

    // MARK: - Main Content
    private var mainContent: some View {
        VStack(spacing: 24) {
            // Instructions card
            instructionCard

            // Game state info
            if testViewModel.gameState != .notStarted {
                gameStateCard
            }
        }
        .padding(.horizontal, 24)
    }

    private var instructionCard: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "info.circle.fill")
                    .foregroundColor(.blue)
                Text("検査について")
                    .font(.headline)
                    .fontWeight(.semibold)
                Spacer()
            }

            VStack(alignment: .leading, spacing: 8) {
                InstructionRow(
                    icon: "grid.circle",
                    text: "7×7のグリッドに0〜48の数字が配置されます"
                )
                InstructionRow(
                    icon: "hand.tap",
                    text: "0から順番に48まで数字をタップしてください"
                )
                InstructionRow(
                    icon: "timer",
                    text: "完了までの時間を計測します"
                )
                InstructionRow(
                    icon: "target",
                    text: "正確性と速さの両方が重要です"
                )
            }
        }
        .padding(20)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
    }

    private var gameStateCard: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: gameStateIcon)
                    .foregroundColor(gameStateColor)
                Text("現在の状態")
                    .font(.headline)
                    .fontWeight(.semibold)
                Spacer()
            }

            HStack {
                Text(testViewModel.gameState.displayName)
                    .font(.subheadline)
                    .foregroundColor(gameStateColor)
                Spacer()

                if testViewModel.gameState.shouldShowTimer {
                    TimerView(
                        elapsedTime: testViewModel.elapsedTime,
                        gameState: testViewModel.gameState,
                        style: .compact
                    )
                }
            }
        }
        .padding(16)
        .background(gameStateColor.opacity(0.1))
        .cornerRadius(12)
    }

    // MARK: - Button Section
    private var buttonSection: some View {
        VStack(spacing: 16) {
            // Main action button
            Button(action: {
                if testViewModel.gameState.canStartTest {
                    showingConfirmation = true
                } else {
                    handleResumeOrStop()
                }
            }) {
                Text(mainButtonTitle)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(mainButtonColor)
                    .cornerRadius(12)
            }
            .disabled(!mainButtonEnabled)

            // Secondary buttons
            HStack(spacing: 12) {
                Button(action: {
                    showingHistory = true
                }) {
                    HStack {
                        Image(systemName: "clock.arrow.circlepath")
                        Text("履歴確認")
                    }
                    .font(.callout)
//                    .fontWeight(.semibold)
                    .foregroundColor(.blue)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(10)
                }

                Button(action: {
                    showingSettings = true
                }) {
                    HStack {
                        Image(systemName: "gear")
                        Text("設定")
                    }
                    .font(.callout)
//                    .fontWeight(.semibold)
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                }
            }
        }
        .padding(.horizontal, 24)
    }

    // MARK: - Quick Stats Section
    private var quickStatsSection: some View {
        VStack(spacing: 12) {
            Text("クイック統計")
                .font(.headline)
                .fontWeight(.semibold)

            HStack(spacing: 20) {
                StatItem(
                    title: "検査回数",
                    value: "\(historyViewModel.testResults.count)",
                    icon: "number.circle"
                )

                StatItem(
                    title: "平均時間",
                    value: historyViewModel.averageTime,
                    icon: "clock"
                )

                StatItem(
                    title: "最短時間",
                    value: historyViewModel.bestTime,
                    icon: "star.circle"
                )
            }
        }
        .padding(20)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(16)
        .padding(.horizontal, 24)
    }

    // MARK: - Computed Properties
    private var backgroundGradient: LinearGradient {
        LinearGradient(
            gradient: Gradient(colors: [
                Color(.systemBackground),
                Color(.systemBackground).opacity(0.8)
            ]),
            startPoint: .top,
            endPoint: .bottom
        )
    }

    private var gameStateIcon: String {
        switch testViewModel.gameState {
        case .notStarted: return "play.circle"
        case .inProgress: return "pause.circle"
        case .paused: return "play.circle"
        case .completed: return "checkmark.circle"
        case .cancelled: return "xmark.circle"
        default: return "questionmark.circle"
        }
    }

    private var gameStateColor: Color {
        switch testViewModel.gameState {
        case .notStarted: return .blue
        case .inProgress: return .green
        case .paused: return .orange
        case .completed: return .green
        case .cancelled: return .red
        default: return .gray
        }
    }

    private var mainButtonTitle: String {
        switch testViewModel.gameState {
        case .notStarted, .completed, .cancelled:
            return "検査開始"
        case .inProgress:
            return "検査を一時停止"
        case .paused:
            return "検査を再開"
        default:
            return "検査開始"
        }
    }

    private var mainButtonColor: Color {
        switch testViewModel.gameState {
        case .notStarted, .completed, .cancelled:
            return .blue
        case .inProgress:
            return .orange
        case .paused:
            return .green
        default:
            return .blue
        }
    }

    private var mainButtonEnabled: Bool {
        switch testViewModel.gameState {
        case .countdown:
            return false
        default:
            return true
        }
    }

    // MARK: - Private Methods
    private func startTest() {
        testViewModel.startCountdown()
        showingCountdown = true
    }

    private func handleResumeOrStop() {
        switch testViewModel.gameState {
        case .inProgress:
            testViewModel.pauseTest()
        case .paused:
            testViewModel.resumeTest()
        default:
            break
        }
    }
}

// MARK: - Supporting Views
struct InstructionRow: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .frame(width: 20)

            Text(text)
                .font(.callout)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.leading)

            Spacer()
        }
    }
}

struct StatItem: View {
    let title: String
    let value: String
    let icon: String

    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.blue)

            Text(value)
                .font(.callout)
                .fontWeight(.semibold)
                .monospacedDigit()

            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Settings View (Placeholder)
struct SettingsView: View {
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            VStack {
                Text("設定画面")
                    .font(.title)

                Text("今後の機能拡張予定")
                    .font(.caption)
                    .foregroundColor(.secondary)

                Spacer()
            }
            .navigationTitle("設定")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完了") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    StartView()
        .environmentObject(TestViewModel(
            timerService: MockTimerService(),
            dataService: MockDataService()
        ))
        .environmentObject(MockHistoryViewModel())
}
