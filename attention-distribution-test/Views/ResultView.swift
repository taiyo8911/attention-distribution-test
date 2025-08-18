//
//  ResultView.swift
//  attention-distribution-test
//
//  Created by Taiyo KOSHIBA on 2025/08/18.
//

import SwiftUI

struct ResultView: View {
    @EnvironmentObject var testViewModel: TestViewModel
    @StateObject private var historyViewModel = HistoryViewModel()

    @State private var showingHistory = false
    @State private var showingShareSheet = false
    @State private var showCompletionAnimation = false
    @State private var showDetailedStats = false

    @Environment(\.dismiss) var dismiss

    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(spacing: 30) {
                    // Header with completion animation
                    completionHeader

                    // Main result card
                    mainResultCard

                    // Performance analysis
                    performanceAnalysisCard

                    // Comparison with history
                    if historyViewModel.hasResults {
                        comparisonCard
                    }

                    // Action buttons
                    actionButtonsSection
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 30)
            }
        }
        .navigationBarHidden(true)
        .background(backgroundGradient)
        .sheet(isPresented: $showingHistory) {
            HistoryView()
                .environmentObject(historyViewModel)
        }
        .sheet(isPresented: $showingShareSheet) {
            ShareSheet(activityItems: [shareText])
        }
        .onAppear {
            setupView()
        }
    }

    // MARK: - Completion Header
    private var completionHeader: some View {
        VStack(spacing: 20) {
            // Success animation
            ZStack {
                Circle()
                    .fill(LinearGradient(
                        gradient: Gradient(colors: [.green.opacity(0.2), .green.opacity(0.1)]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .frame(width: 120, height: 120)
                    .scaleEffect(showCompletionAnimation ? 1.0 : 0.3)
                    .animation(.spring(response: 0.6, dampingFraction: 0.6), value: showCompletionAnimation)

                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.green)
                    .scaleEffect(showCompletionAnimation ? 1.0 : 0.3)
                    .animation(.spring(response: 0.8, dampingFraction: 0.6).delay(0.2), value: showCompletionAnimation)
            }

            VStack(spacing: 8) {
                Text("検査完了！")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)

                Text("お疲れさまでした")
                    .font(.title3)
                    .foregroundColor(.secondary)
            }
            .opacity(showCompletionAnimation ? 1.0 : 0.0)
            .animation(.easeInOut(duration: 0.6).delay(0.4), value: showCompletionAnimation)
        }
    }

    // MARK: - Main Result Card
    private var mainResultCard: some View {
        VStack(spacing: 20) {
            // Completion time
            VStack(spacing: 8) {
                Text("完了時間")
                    .font(.headline)
                    .foregroundColor(.secondary)

                Text(testViewModel.elapsedTime.formattedTime)
                    .font(.system(size: 48, weight: .bold, design: .monospaced))
                    .foregroundColor(.blue)
                    .minimumScaleFactor(0.7)
            }

            Divider()

            // Quick stats grid
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
                StatCard(
                    title: "平均応答時間",
                    value: averageResponseTime,
                    icon: "timer",
                    color: .orange
                )

                StatCard(
                    title: "正確率",
                    value: "100%",
                    icon: "target",
                    color: .green
                )

                StatCard(
                    title: "デバイス",
                    value: DeviceType.current.displayName,
                    icon: "iphone",
                    color: .purple
                )

                StatCard(
                    title: "日時",
                    value: formattedDate,
                    icon: "calendar",
                    color: .blue
                )
            }
        }
        .padding(24)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
    }

    // MARK: - Performance Analysis Card
    private var performanceAnalysisCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "chart.bar.fill")
                    .foregroundColor(.blue)
                Text("パフォーマンス分析")
                    .font(.headline)
                    .fontWeight(.semibold)
                Spacer()

                Button(action: {
                    showDetailedStats.toggle()
                }) {
                    Image(systemName: showDetailedStats ? "chevron.up" : "chevron.down")
                        .foregroundColor(.blue)
                }
            }

            // Performance indicators
            VStack(spacing: 12) {
                PerformanceIndicator(
                    title: "速度",
                    value: speedRating,
                    maxValue: 5,
                    color: .blue
                )

                PerformanceIndicator(
                    title: "一貫性",
                    value: consistencyRating,
                    maxValue: 5,
                    color: .green
                )

                PerformanceIndicator(
                    title: "集中力",
                    value: focusRating,
                    maxValue: 5,
                    color: .orange
                )
            }

            if showDetailedStats {
                Divider()

                VStack(alignment: .leading, spacing: 8) {
                    Text("詳細統計")
                        .font(.subheadline)
                        .fontWeight(.semibold)

                    DetailedStatRow(label: "総タップ数", value: "48")
                    DetailedStatRow(label: "誤タップ数", value: "0") // This would come from tap history
                    DetailedStatRow(label: "最速応答", value: "0.8秒") // This would be calculated
                    DetailedStatRow(label: "最遅応答", value: "3.2秒") // This would be calculated
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .padding(20)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
        .animation(.easeInOut(duration: 0.3), value: showDetailedStats)
    }

    // MARK: - Comparison Card
    private var comparisonCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "chart.line.uptrend.xyaxis")
                    .foregroundColor(.green)
                Text("過去の結果との比較")
                    .font(.headline)
                    .fontWeight(.semibold)
                Spacer()
            }

            HStack(spacing: 20) {
                ComparisonItem(
                    title: "自己ベスト",
                    currentValue: testViewModel.elapsedTime.formattedTime,
                    comparisonValue: historyViewModel.bestTime,
                    isImprovement: isPersonalBest
                )

                ComparisonItem(
                    title: "平均との差",
                    currentValue: testViewModel.elapsedTime.formattedTime,
                    comparisonValue: historyViewModel.averageTime,
                    isImprovement: isBetterThanAverage
                )
            }

            if historyViewModel.hasResults {
                Text(improvementMessage)
                    .font(.callout)
                    .foregroundColor(.secondary)
                    .padding(.top, 8)
            }
        }
        .padding(20)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
    }

    // MARK: - Action Buttons
    private var actionButtonsSection: some View {
        VStack(spacing: 16) {
            // Primary actions
            HStack(spacing: 12) {
                Button(action: {
                    startNewTest()
                }) {
                    HStack {
                        Image(systemName: "arrow.clockwise")
                        Text("もう一度")
                    }
                    .font(.title3)
//                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(.blue)
                    .cornerRadius(12)
                }

                Button(action: {
                    showingHistory = true
                }) {
                    HStack {
                        Image(systemName: "clock.arrow.circlepath")
                        Text("履歴")
                    }
                    .font(.title3)
//                    .fontWeight(.semibold)
                    .foregroundColor(.blue)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(12)
                }
            }

            // Secondary actions
            HStack(spacing: 12) {
                Button(action: {
                    showingShareSheet = true
                }) {
                    HStack {
                        Image(systemName: "square.and.arrow.up")
                        Text("結果を共有")
                    }
                    .font(.callout)
//                    .fontWeight(.medium)
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                }

                Button(action: {
                    dismiss()
                }) {
                    HStack {
                        Image(systemName: "house")
                        Text("メインへ")
                    }
                    .font(.callout)
//                    .fontWeight(.medium)
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                }
            }
        }
    }

    // MARK: - Computed Properties
    private var backgroundGradient: LinearGradient {
        LinearGradient(
            gradient: Gradient(colors: [
                Color(.systemBackground),
                Color(.systemBackground).opacity(0.9),
                Color.blue.opacity(0.05)
            ]),
            startPoint: .top,
            endPoint: .bottom
        )
    }

    private var averageResponseTime: String {
        let avgTime = testViewModel.elapsedTime / 48.0 // 48 numbers total
        return String(format: "%.1f秒", avgTime)
    }

    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd"
        return formatter.string(from: Date())
    }

    private var speedRating: Int {
        // Calculate speed rating based on completion time
        // This is a simplified calculation
        let time = testViewModel.elapsedTime
        if time < 120 { return 5 }
        else if time < 150 { return 4 }
        else if time < 180 { return 3 }
        else if time < 240 { return 2 }
        else { return 1 }
    }

    private var consistencyRating: Int {
        // This would be calculated based on variance in response times
        // For now, returning a mock value
        return 4
    }

    private var focusRating: Int {
        // This would be calculated based on error rate and response time stability
        // For now, returning a mock value
        return 5
    }

    private var isPersonalBest: Bool {
        // This would be determined by comparing with history
        return false // Placeholder
    }

    private var isBetterThanAverage: Bool {
        // This would be determined by comparing with average
        return false // Placeholder
    }

    private var improvementMessage: String {
        if isPersonalBest {
            return "🎉 新記録です！素晴らしい結果です。"
        } else if isBetterThanAverage {
            return "👍 平均を上回る良い結果です。"
        } else {
            return "📈 次回はさらに良い結果を目指しましょう。"
        }
    }

    private var shareText: String {
        return """
        注意配分検査の結果
        
        完了時間: \(testViewModel.elapsedTime.formattedTime)
        平均応答時間: \(averageResponseTime)
        日時: \(Date().formatted())
        
        #注意配分検査 #運転適性検査
        """
    }

    // MARK: - Methods
    private func setupView() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.6)) {
                showCompletionAnimation = true
            }
        }

        Task {
            await historyViewModel.loadTestResults()
        }
    }

    private func startNewTest() {
        testViewModel.resetTest()
        dismiss()
    }
}

// MARK: - Supporting Views
struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)

            Text(value)
                .font(.callout)
                .fontWeight(.semibold)
                .multilineTextAlignment(.center)

            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(color.opacity(0.1))
        .cornerRadius(12)
    }
}

struct PerformanceIndicator: View {
    let title: String
    let value: Int
    let maxValue: Int
    let color: Color

    var body: some View {
        VStack(spacing: 6) {
            HStack {
                Text(title)
                    .font(.callout)
                    .fontWeight(.medium)
                Spacer()
                Text("\(value)/\(maxValue)")
                    .font(.callout)
                    .fontWeight(.semibold)
                    .foregroundColor(color)
            }

            HStack(spacing: 4) {
                ForEach(1...maxValue, id: \.self) { index in
                    RoundedRectangle(cornerRadius: 2)
                        .fill(index <= value ? color : Color.gray.opacity(0.3))
                        .frame(height: 6)
                }
            }
        }
    }
}

struct DetailedStatRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .font(.caption)
                .fontWeight(.medium)
        }
    }
}

struct ComparisonItem: View {
    let title: String
    let currentValue: String
    let comparisonValue: String
    let isImprovement: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)

            Text(currentValue)
                .font(.callout)
                .fontWeight(.semibold)

            HStack(spacing: 4) {
                Image(systemName: isImprovement ? "arrow.up.circle.fill" : "arrow.down.circle.fill")
                    .font(.caption)
                    .foregroundColor(isImprovement ? .green : .red)

                Text("vs \(comparisonValue)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#Preview {
    let testViewModel = TestViewModel(
        timerService: MockTimerService(),
        dataService: MockDataService()
    )

    return ResultView()
        .environmentObject(testViewModel)
}
