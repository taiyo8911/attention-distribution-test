//
//  HistoryView.swift
//  attention-distribution-test
//
//  Created by Taiyo KOSHIBA on 2025/08/18.
//

import SwiftUI

struct HistoryView: View {
    @EnvironmentObject var historyViewModel: HistoryViewModel // 履歴データを管理するViewModel
    @Environment(\.dismiss) var dismiss // 画面を閉じるための環境変数
    @State private var showingDeleteConfirmation = false // 全削除確認アラート用の変数

    var body: some View {
        VStack(spacing: 0) {
            if historyViewModel.testResults.isEmpty {
                emptyStateView
            } else {
                statisticsSection
                historyList
            }
        }
        .navigationTitle("History")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            // 履歴がある時だけ「全削除」を表示
            ToolbarItem(placement: .navigationBarLeading) {
                if !historyViewModel.testResults.isEmpty {
                    Button("Delete All", role: .destructive) {
                        showingDeleteConfirmation = true
                    }
                    .foregroundColor(.red)
                }
            }

            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Back") {
                    dismiss()
                }
            }
        }
        // 画面が表示されたときに履歴データを読み込む
        .onAppear {
            Task {
                await historyViewModel.loadTestResults()
            }
        }
        // 全削除確認アラート
        .alert("Delete all history?", isPresented: $showingDeleteConfirmation) {
            Button("Delete", role: .destructive) {
                Task {
                    await historyViewModel.deleteAllTestResults()
                }
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("This action cannot be undone.")
        }
        .dynamicTypeSize(...DynamicTypeSize.xxxLarge)
    }

    // 履歴が無い場合の表示
    private var emptyStateView: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: "clock.badge.questionmark")
                .font(.system(size: 64))
                .foregroundColor(.gray)

            Text("No history yet")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.primary)

            Spacer()
        }
    }

    private var historyList: some View {
        List {
            ForEach(historyViewModel.testResults) { result in
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(result.formattedDate)
                            .monospacedDigit()
                    }

                    Spacer()

                    Text(result.formattedTime)
                        .foregroundColor(.blue)
                        .monospacedDigit()
                }
                .padding(.vertical, 8)
            }
        }
        .listStyle(.plain)
    }

    // MARK: - 統計セクション
    private var statisticsSection: some View {
        HStack(spacing: 12) {
            StatisticItem(
                title: "Attempts",
                value: "\(historyViewModel.testCount)",
                unit: nil
            )

            Divider()
                .frame(height: 40)

            StatisticItem(
                title: "Best Time",
                value: historyViewModel.bestTime?.formattedTime ?? "--:--",
                unit: nil
            )

            Divider()
                .frame(height: 40)

            StatisticItem(
                title: "Average",
                value: historyViewModel.averageTime?.formattedTime ?? "--:--",
                unit: nil
            )
        }
        .padding(.vertical, 16)
        .padding(.horizontal, 12)
        .background(Color(.secondarySystemBackground))
    }
}

// MARK: - 統計項目1つ分
private struct StatisticItem: View {
    let title: LocalizedStringKey
    let value: String
    let unit: String?

    var body: some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)

            HStack(alignment: .lastTextBaseline, spacing: 2) {
                Text(value)
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                    .monospacedDigit()

                if let unit {
                    Text(unit)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview("履歴あり") {
    NavigationStack {
        HistoryView()
            .environmentObject(HistoryViewModel(dataService: MockDataService(withMockData: true)))
    }
}

#Preview("履歴なし") {
    NavigationStack {
        HistoryView()
            .environmentObject(HistoryViewModel(dataService: MockDataService(withMockData: false)))
    }
}
