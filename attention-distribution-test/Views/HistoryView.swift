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
        .onAppear {
            Task {
                await historyViewModel.loadTestResults()
            }
        }
    }

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
                            .font(.callout)
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
        .listStyle(PlainListStyle())
    }
}

#Preview {
    NavigationView {
        HistoryView()
            .environmentObject(HistoryViewModel(dataService: MockDataService(withMockData: true)))
    }
}
