//
//  HistoryView.swift
//  attention-distribution-test
//
//  Created by Taiyo KOSHIBA on 2025/08/18.
//



import SwiftUI

struct HistoryView: View {
    @EnvironmentObject var testManager: TestManager
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            VStack {
                if testManager.testResults.isEmpty {
                    // 履歴がない場合
                    VStack(spacing: 20) {
                        Spacer()
                        
                        Image(systemName: "clock.badge.questionmark")
                            .font(.system(size: 64))
                            .foregroundColor(.gray)
                        
                        Text("履歴がありません")
                            .font(.title2)
                            .foregroundColor(.secondary)
                        
                        Text("検査を完了すると履歴が表示されます")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                        
                        Spacer()
                    }
                } else {
                    // 履歴リスト
                    List {
                        ForEach(Array(testManager.testResults.enumerated()), id: \.offset) { index, result in
                            HistoryRow(result: result, rank: index + 1)
                        }
                    }
                    .listStyle(PlainListStyle())
                    
                    // 統計情報
                    if !testManager.testResults.isEmpty {
                        statisticsSection
                    }
                }
            }
            .navigationTitle("履歴")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("閉じる") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    // MARK: - Statistics Section
    private var statisticsSection: some View {
        VStack(spacing: 16) {
            Divider()
            
            Text("統計情報")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack {
                StatisticCard(
                    title: "検査回数",
                    value: "\(testManager.testResults.count)回",
                    color: .blue
                )
                
                StatisticCard(
                    title: "平均時間",
                    value: averageTime,
                    color: .green
                )
                
                if testManager.testResults.count > 1 {
                    StatisticCard(
                        title: "最短時間",
                        value: bestTime,
                        color: .orange
                    )
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
    }
    
    // MARK: - Computed Properties
    private var averageTime: String {
        guard !testManager.testResults.isEmpty else { return "--" }
        let total = testManager.testResults.reduce(0) { $0 + $1.completionTime }
        let average = total / Double(testManager.testResults.count)
        return average.formattedTime
    }
    
    private var bestTime: String {
        guard let best = testManager.testResults.min(by: { $0.completionTime < $1.completionTime }) else {
            return "--"
        }
        return best.completionTime.formattedTime
    }
}

// MARK: - History Row Component
struct HistoryRow: View {
    let result: TestResult
    let rank: Int
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd HH:mm"
        return formatter
    }()
    
    var body: some View {
        HStack {
            // ランキング表示
            Text("\(rank)")
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .frame(width: 24, height: 24)
                .background(rankColor)
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 4) {
                Text(dateFormatter.string(from: result.date))
                    .font(.subheadline)
                    .foregroundColor(.primary)
                
                HStack {
                    Text(result.deviceType)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                }
            }
            
            Spacer()
            
            // 完了時間
            Text(result.completionTime.formattedTime)
                .font(.subheadline)
                .fontWeight(.semibold)
                .monospacedDigit()
        }
        .padding(.vertical, 4)
    }
    
    private var rankColor: Color {
        switch rank {
        case 1: return .yellow
        case 2: return .gray
        case 3: return .brown
        default: return .blue
        }
    }
}

// MARK: - Statistic Card Component
struct StatisticCard: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text(value)
                .font(.subheadline)
                .fontWeight(.bold)
                .foregroundColor(color)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.white)
        .cornerRadius(8)
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
}

#Preview {
    HistoryView()
        .environmentObject(TestManager())
}
