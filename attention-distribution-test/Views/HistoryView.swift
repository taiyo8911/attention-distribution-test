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

    var body: some View {
        VStack {
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
        // 画面が表示されたときに履歴データを読み込む
        .onAppear {
            Task {
                await historyViewModel.loadTestResults()
            }
        }
    }

    // 履歴が無い場合の表示
    private var emptyStateView: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: "clock.badge.questionmark")
                .font(.system(size: 64))
                .foregroundColor(.gray)

            Text("履歴はありません")
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
        .listStyle(PlainListStyle())
    }
}

#Preview {
    NavigationView {
        HistoryView()
            .environmentObject(HistoryViewModel(dataService: MockDataService(withMockData: true)))
    }
}
