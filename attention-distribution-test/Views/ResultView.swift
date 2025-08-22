//
//  ResultView.swift
//  attention-distribution-test
//
//  Created by Taiyo KOSHIBA on 2025/08/18.
//

import SwiftUI

struct ResultView: View {
    @EnvironmentObject var testViewModel: TestViewModel
    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack(spacing: 50) {
            Spacer()

            // タイトル
            Text("検査終了")
                .font(.largeTitle)
                .fontWeight(.bold)

            // 完了時間
            VStack(spacing: 8) {
                Text("完了時間")
                    .font(.headline)
                    .foregroundColor(.secondary)

                Text(formattedCompletionTime)
                    .font(.system(size: 48, weight: .bold, design: .monospaced))
                    .foregroundColor(.blue)
                    .monospacedDigit()
            }

            Spacer()

            // ボタン
            VStack(spacing: 16) {
                Button("もう一度") {
                    testViewModel.resetTest()
                    dismiss()
                }
                .font(.title3)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(.blue)
                .cornerRadius(12)

                Button("メインへ戻る") {
                    dismiss()
                }
                .font(.title3)
                .foregroundColor(.red)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Color.red.opacity(0.1))
                .cornerRadius(12)
            }
            .padding(.horizontal, 20)

            Spacer()
        }
        .navigationBarHidden(true)
    }

    private var formattedCompletionTime: String {
        let minutes = Int(testViewModel.elapsedTime) / 60
        let seconds = Int(testViewModel.elapsedTime) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

#Preview {
    let testViewModel = TestViewModel(
        timerService: MockTimerService(),
        dataService: MockDataService()
    )

    return ResultView()
        .environmentObject(testViewModel)
}
