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

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                if historyViewModel.testResults.isEmpty {
                    emptyStateView
                } else {
                    historyList
                }
            }
            .navigationTitle("履歴")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("戻る") {
                        dismiss()
                    }
                }
            }
        }
        .onAppear {
            Task {
                await historyViewModel.loadTestResults()
            }
        }
    }

    // MARK: - Empty State View
    private var emptyStateView: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: "clock.badge.questionmark")
                .font(.system(size: 64))
                .foregroundColor(.gray.opacity(0.6))

            VStack(spacing: 8) {
                Text("履歴はありません")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
            }

            Spacer()
        }
        .padding(.horizontal, 40)
    }

    // MARK: - History List
    private var historyList: some View {
        List {
            ForEach(historyViewModel.testResults) { result in
                HistoryRow(result: result)
            }
        }
        .listStyle(PlainListStyle())
    }
}

// MARK: - History Row Component
struct HistoryRow: View {
    let result: TestResult

    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd HH:mm"
        return formatter
    }()

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(dateFormatter.string(from: result.date))
                    .font(.callout)
                    .foregroundColor(.primary)

                Text(result.deviceType.displayName)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            Text(result.formattedTime)
                .font(.callout)
                .fontWeight(.semibold)
                .foregroundColor(.blue)
                .monospacedDigit()
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    HistoryView()
        .environmentObject(HistoryViewModel())
}
