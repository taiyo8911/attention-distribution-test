//
//  ResultView.swift
//  attention-distribution-test
//
//  Created by Taiyo KOSHIBA on 2025/08/18.
//

import SwiftUI

struct ResultView: View {
    @EnvironmentObject var testViewModel: TestViewModel
    @State private var advice: String = "" // 表示するワンポイントアドバイス

    let onReturnToStart: () -> Void // メイン画面へ戻るコールバック

    var body: some View {
        VStack(spacing: 30) {
            Spacer()

            // タイトル
            Text("検査終了")
                .font(.largeTitle)
                .fontWeight(.bold)

            // 完了時間
            VStack(spacing: 8) {
                Text("完了時間")
                    .font(.title2)
                    .foregroundColor(.secondary)

                Text(testViewModel.elapsedTime.formattedTime)
                    .font(.system(size: 48, weight: .bold, design: .monospaced))
                    .foregroundColor(.blue)
                    .monospacedDigit()
            }

            // ワンポイントアドバイス
            adviceCard

            Spacer()

            // メインへ戻るボタン
            Button("メイン画面へ戻る") {
                onReturnToStart()
            }
            .font(.title3)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(.blue)
            .cornerRadius(12)
            .padding(.horizontal, 20)

            Spacer()
        }
        .toolbar(.hidden, for: .navigationBar)
        .onAppear {
            // 画面表示のたびにランダムで1つ選ぶ
            advice = TestAdvice.random()
        }
        .dynamicTypeSize(...DynamicTypeSize.accessibility2)
    }

    // MARK: - ワンポイントアドバイスカード
    private var adviceCard: some View {
        VStack(spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "lightbulb.fill")
                    .foregroundColor(.yellow)
                Text("ワンポイントアドバイス")
                    .font(.headline)
                    .foregroundColor(.primary)
            }

            Text(advice)
                .font(.body)
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(20)
        .frame(maxWidth: .infinity)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(16)
        .padding(.horizontal, 20)
    }
}

#Preview {
    let testViewModel = TestViewModel(
        timerService: MockTimerService(),
        dataService: MockDataService()
    )

    return ResultView(onReturnToStart: {})
        .environmentObject(testViewModel)
}
