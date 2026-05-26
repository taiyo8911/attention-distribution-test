//
//  TestStatusBar.swift
//  attention-distribution-test
//
//  Created by Taiyo KOSHIBA on 2025/08/18.
//

import SwiftUI

// タイマー・中断ボタン・現在の数字・エラーメッセージをまとめたステータスバー
// 縦・横レイアウトで共通利用する
struct TestStatusBar: View {
    @EnvironmentObject var testViewModel: TestViewModel

    // タイマー
    let timerFontSize: CGFloat
    var timerTopPadding: CGFloat = 0

    // 中断ボタン
    let stopButtonWidth: CGFloat
    let stopButtonHeight: CGFloat
    let stopButtonFont: Font
    var stopButtonCornerRadius: CGFloat = 8

    // 次に押す数字
    let numberFontSize: CGFloat
    var numberFontWeight: Font.Weight = .regular
    let numberPlaceholderHeight: CGFloat

    // エラーメッセージ
    let errorFont: Font
    var errorPlaceholderHeight: CGFloat = 16

    // アクション
    let onStopTapped: () -> Void

    var body: some View {
        Group {
            // タイマー
            Text(testViewModel.elapsedTime.formattedTime)
                .font(.system(size: timerFontSize, weight: .bold, design: .monospaced))
                .monospacedDigit()
                .padding(.top, timerTopPadding)

            // 中断ボタン
            Button("やめる") {
                onStopTapped()
            }
            .font(stopButtonFont)
            .foregroundColor(.white)
            .frame(width: stopButtonWidth, height: stopButtonHeight)
            .background(.red)
            .cornerRadius(stopButtonCornerRadius)

            // 次に押す数字
            if testViewModel.currentNumber <= testViewModel.targetNumber {
                Text("\(testViewModel.currentNumber)")
                    .font(.system(size: numberFontSize, weight: numberFontWeight))
            } else {
                Text("")
                    .font(.system(size: numberFontSize))
                    .frame(height: numberPlaceholderHeight)
            }

            // エラーメッセージ
            if testViewModel.showError {
                Text("正しい数字をタップしてください")
                    .foregroundColor(.red)
                    .font(errorFont)
                    .multilineTextAlignment(.center)
            } else {
                Text("")
                    .font(errorFont)
                    .frame(height: errorPlaceholderHeight)
            }
        }
    }
}
