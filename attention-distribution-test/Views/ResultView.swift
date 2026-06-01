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

    let onRestart: () -> Void // もう一度挑戦するコールバック
    let onReturnToStart: () -> Void // メイン画面へ戻るコールバック

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            // タイトルとねぎらいメッセージ
            VStack(spacing: 8) {
                Text("Test Complete")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Text("Well done!")
                    .font(.title3)
                    .foregroundColor(.secondary)
            }

            // 自己ベスト更新バッジ
            if testViewModel.isPersonalBest {
                personalBestBadge
            }

            // 完了時間
            VStack(spacing: 8) {
                Text("Completion Time")
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

            // アクションボタン
            VStack(spacing: 12) {
                // もう一度挑戦ボタン（主アクション）
                Button("Try Again") {
                    onRestart()
                }
                .font(.title3)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(.blue)
                .cornerRadius(12)

                // メイン画面へ戻るボタン（副アクション）
                Button("Back to Home") {
                    onReturnToStart()
                }
                .font(.title3)
                .foregroundColor(.blue)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Color.blue.opacity(0.1))
                .cornerRadius(12)
            }
            .padding(.horizontal, 20)
        }
        .toolbar(.hidden, for: .navigationBar)
        .onAppear {
            // 画面表示のたびにランダムで1つ選ぶ
            advice = TestAdvice.random()
        }
        .dynamicTypeSize(...DynamicTypeSize.accessibility2)
    }

    // MARK: - 自己ベスト更新バッジ
    private var personalBestBadge: some View {
        HStack(spacing: 6) {
            Image(systemName: "star.fill")
                .foregroundColor(.yellow)
            Text("New Personal Best!")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.orange)
            Image(systemName: "star.fill")
                .foregroundColor(.yellow)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(Color.yellow.opacity(0.15))
        .cornerRadius(20)
    }

    // MARK: - ワンポイントアドバイスカード
    private var adviceCard: some View {
        VStack(spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "lightbulb.fill")
                    .foregroundColor(.yellow)
                Text("Tip")
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

#if DEBUG
#Preview("通常") {
    ResultView(onRestart: {}, onReturnToStart: {})
        .environmentObject(TestViewModel.preview(elapsedTime: 142))
}

#Preview("自己ベスト更新") {
    ResultView(onRestart: {}, onReturnToStart: {})
        .environmentObject(TestViewModel.preview(elapsedTime: 98, isPersonalBest: true))
}
#endif
