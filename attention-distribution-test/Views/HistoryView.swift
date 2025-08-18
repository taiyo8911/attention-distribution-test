//
//  HistoryView.swift
//  attention-distribution-test
//
//  Created by Taiyo KOSHIBA on 2025/08/18.
//

import SwiftUI

struct HistoryView: View {
    @EnvironmentObject var historyViewModel: HistoryViewModel
    @Environment(\.dismiss) var dismiss

    @State private var selectedSortOption: HistoryViewModel.SortOption = .dateNewest
    @State private var selectedFilterOption: HistoryViewModel.FilterOption = .all
    @State private var showingExportOptions = false
    @State private var showingClearConfirmation = false
    @State private var showingChartView = false

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                if historyViewModel.isLoading {
                    loadingView
                } else if historyViewModel.hasResults {
                    contentView
                } else {
                    emptyStateView
                }
            }
            .navigationTitle("検査履歴")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("閉じる") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button(action: {
                            showingChartView = true
                        }) {
                            Label("グラフ表示", systemImage: "chart.line.uptrend.xyaxis")
                        }

                        Button(action: {
                            showingExportOptions = true
                        }) {
                            Label("エクスポート", systemImage: "square.and.arrow.up")
                        }

                        Divider()

                        Button(action: {
                            Task { await historyViewModel.refresh() }
                        }) {
                            Label("更新", systemImage: "arrow.clockwise")
                        }

                        Button(action: {
                            showingClearConfirmation = true
                        }) {
                            Label("履歴をクリア", systemImage: "trash")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                    .disabled(!historyViewModel.hasResults)
                }
            }
        }
        .sheet(isPresented: $showingChartView) {
            ChartView()
                .environmentObject(historyViewModel)
        }
        .confirmationDialog("エクスポート形式を選択", isPresented: $showingExportOptions) {
            Button("JSON形式") {
                exportResults(format: .json)
            }
            Button("CSV形式") {
                exportResults(format: .csv)
            }
            Button("キャンセル", role: .cancel) { }
        }
        .alert("履歴をクリアしますか？", isPresented: $showingClearConfirmation) {
            Button("クリア", role: .destructive) {
                Task {
                    await historyViewModel.clearAllResults()
                }
            }
            Button("キャンセル", role: .cancel) { }
        } message: {
            Text("この操作は取り消せません。すべての検査履歴が削除されます。")
        }
        .onAppear {
            Task {
                await historyViewModel.loadTestResults()
            }
        }
    }

    // MARK: - Loading View
    private var loadingView: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.2)

            Text("履歴を読み込み中...")
                .font(.callout)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Empty State View
    private var emptyStateView: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: "clock.badge.questionmark")
                .font(.system(size: 64))
                .foregroundColor(.gray.opacity(0.6))

            VStack(spacing: 8) {
                Text("履歴がありません")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)

                Text("検査を完了すると履歴が表示されます")
                    .font(.callout)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }

            Button(action: {
                dismiss()
            }) {
                Text("検査を開始する")
                    .font(.callout)
                    .fontWeight(.semibold)
                    .foregroundColor(.blue)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(20)
            }

            Spacer()
        }
        .padding(.horizontal, 40)
    }

    // MARK: - Content View
    private var contentView: some View {
        VStack(spacing: 0) {
            // Statistics section
            statisticsSection

            // Filter and sort controls
            filterSortSection

            // Results list
            resultsList
        }
    }

    // MARK: - Statistics Section
    private var statisticsSection: some View {
        VStack(spacing: 16) {
            Text("統計情報")
                .font(.headline)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity, alignment: .leading)

            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 16) {
                StatisticCard(
                    title: "検査回数",
                    value: "\(historyViewModel.testResults.count)回",
                    color: .blue,
                    icon: "number.circle"
                )

                StatisticCard(
                    title: "平均時間",
                    value: historyViewModel.averageTime,
                    color: .green,
                    icon: "clock"
                )

                StatisticCard(
                    title: "最短時間",
                    value: historyViewModel.bestTime,
                    color: .orange,
                    icon: "star.circle"
                )
            }

            // Recent trend
            if let statistics = historyViewModel.statistics, statistics.totalTests >= 10 {
                HStack {
                    Text("最近の傾向:")
                        .font(.callout)
                        .foregroundColor(.secondary)

                    Text(historyViewModel.improvementTrend)
                        .font(.callout)
                        .fontWeight(.semibold)
                        .foregroundColor(historyViewModel.improvementColor)

                    Spacer()
                }
                .padding(.top, 8)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(Color(.systemGray6))
    }

    // MARK: - Filter and Sort Section
    private var filterSortSection: some View {
        HStack {
            // Sort picker
            Menu {
                ForEach(HistoryViewModel.SortOption.allCases, id: \.self) { option in
                    Button(action: {
                        selectedSortOption = option
                    }) {
                        HStack {
                            Text(option.displayName)
                            if selectedSortOption == option {
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                }
            } label: {
                HStack {
                    Image(systemName: "arrow.up.arrow.down")
                    Text(selectedSortOption.displayName)
                }
                .font(.callout)
                .foregroundColor(.blue)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color.blue.opacity(0.1))
                .cornerRadius(8)
            }

            Spacer()

            // Filter picker
            Menu {
                ForEach(HistoryViewModel.FilterOption.allCases, id: \.self) { option in
                    Button(action: {
                        selectedFilterOption = option
                    }) {
                        HStack {
                            Text(option.displayName)
                            if selectedFilterOption == option {
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                }
            } label: {
                HStack {
                    Image(systemName: "line.3.horizontal.decrease.circle")
                    Text(selectedFilterOption.displayName)
                }
                .font(.callout)
                .foregroundColor(.purple)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color.purple.opacity(0.1))
                .cornerRadius(8)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(Color(.systemBackground))
    }

    // MARK: - Results List
    private var resultsList: some View {
        let filteredResults = historyViewModel.getSortedAndFilteredResults(
            sortBy: selectedSortOption,
            filterBy: selectedFilterOption
        )

        return List {
            ForEach(Array(filteredResults.enumerated()), id: \.element.id) { index, result in
                HistoryRow(
                    result: result,
                    rank: getRankForResult(result, in: filteredResults),
                    isPersonalBest: result.id == historyViewModel.getPersonalBest()?.id
                )
                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                    Button("削除", role: .destructive) {
                        Task {
                            await historyViewModel.deleteResult(result)
                        }
                    }
                }
            }
        }
        .listStyle(PlainListStyle())
        .refreshable {
            await historyViewModel.refresh()
        }
    }

    // MARK: - Helper Methods
    private func getRankForResult(_ result: TestResult, in results: [TestResult]) -> Int {
        let sortedByTime = results.sorted { $0.completionTime < $1.completionTime }
        return (sortedByTime.firstIndex(of: result) ?? 0) + 1
    }

    private func exportResults(format: ExportFormat) {
        Task {
            if let data = await historyViewModel.exportResults(format: format) {
                // Handle the exported data (share sheet, save to files, etc.)
                // For now, we'll just print success
                print("Exported \(data.count) bytes as \(format)")
            }
        }
    }
}

// MARK: - History Row Component
struct HistoryRow: View {
    let result: TestResult
    let rank: Int
    let isPersonalBest: Bool

    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd HH:mm"
        return formatter
    }()

    var body: some View {
        HStack(spacing: 16) {
            // Rank indicator
            rankIndicator

            // Main content
            VStack(alignment: .leading, spacing: 6) {
                // Date and device
                HStack {
                    Text(dateFormatter.string(from: result.date))
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)

                    Spacer()

                    DeviceTag(deviceType: result.deviceType)
                }

                // Time and performance
                HStack {
                    Text(result.completionTime.formattedTime)
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                        .monospacedDigit()

                    Spacer()

                    if isPersonalBest {
                        PersonalBestBadge()
                    }
                }
            }

            // Performance indicator
            performanceIndicator
        }
        .padding(.vertical, 8)
        .background(isPersonalBest ? Color.yellow.opacity(0.1) : Color.clear)
        .cornerRadius(8)
    }

    private var rankIndicator: some View {
        ZStack {
            Circle()
                .fill(rankColor)
                .frame(width: 32, height: 32)

            Text("\(rank)")
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(.white)
        }
    }

    private var rankColor: Color {
        switch rank {
        case 1: return .yellow
        case 2: return .gray
        case 3: return .brown
        default: return .blue
        }
    }

    private var performanceIndicator: some View {
        VStack(spacing: 2) {
            Circle()
                .fill(performanceColor)
                .frame(width: 8, height: 8)

            Text(performanceLevel)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
    }

    private var performanceColor: Color {
        let time = result.completionTime
        if time < 120 { return .green }
        else if time < 180 { return .yellow }
        else { return .red }
    }

    private var performanceLevel: String {
        let time = result.completionTime
        if time < 120 { return "優秀" }
        else if time < 180 { return "良好" }
        else { return "要改善" }
    }
}

// MARK: - Supporting Components
struct StatisticCard: View {
    let title: String
    let value: String
    let color: Color
    let icon: String

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)

            Text(value)
                .font(.callout)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
                .minimumScaleFactor(0.8)

            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}

struct DeviceTag: View {
    let deviceType: DeviceType

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: deviceType == .iPad ? "ipad" : "iphone")
                .font(.caption)
            Text(deviceType.displayName)
                .font(.caption)
        }
        .foregroundColor(.secondary)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color(.tertiarySystemBackground))
        .cornerRadius(6)
    }
}

struct PersonalBestBadge: View {
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "crown.fill")
                .font(.caption)
            Text("PB")
                .font(.caption)
                .fontWeight(.bold)
        }
        .foregroundColor(.yellow)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color.yellow.opacity(0.2))
        .cornerRadius(6)
    }
}

// MARK: - Chart View
struct ChartView: View {
    @EnvironmentObject var historyViewModel: HistoryViewModel
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            VStack {
                if historyViewModel.hasResults {
                    ScrollView {
                        VStack(spacing: 24) {
                            // Time trend chart placeholder
                            chartPlaceholder

                            // Statistics summary
                            chartStatistics
                        }
                        .padding(20)
                    }
                } else {
                    Text("グラフを表示するには\n複数の検査結果が必要です")
                        .font(.callout)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
            }
            .navigationTitle("成績推移")
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

    private var chartPlaceholder: some View {
        VStack(spacing: 16) {
            Text("成績推移グラフ")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)

            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray5))
                .frame(height: 200)
                .overlay(
                    VStack {
                        Image(systemName: "chart.line.uptrend.xyaxis")
                            .font(.title)
                            .foregroundColor(.gray)
                        Text("グラフ機能は今後実装予定")
                            .font(.callout)
                            .foregroundColor(.secondary)
                    }
                )
        }
    }

    private var chartStatistics: some View {
        VStack(spacing: 16) {
            Text("統計サマリー")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)

            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
                ChartStatCard(title: "総検査回数", value: "\(historyViewModel.testResults.count)")
                ChartStatCard(title: "平均時間", value: historyViewModel.averageTime)
                ChartStatCard(title: "最短時間", value: historyViewModel.bestTime)
                ChartStatCard(title: "最近の平均", value: historyViewModel.recentAverage)
            }
        }
    }
}

struct ChartStatCard: View {
    let title: String
    let value: String

    var body: some View {
        VStack(spacing: 8) {
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.blue)

            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(8)
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}

#Preview {
    HistoryView()
        .environmentObject(MockHistoryViewModel())
}
