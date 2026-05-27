//
//  TestStatusBar.swift
//  attention-distribution-test
//
//  Created by Taiyo KOSHIBA on 2025/08/18.
//

import SwiftUI

// 中断ボタン・現在の数字・エラーメッセージをまとめたステータスバー
// 縦・横レイアウトで共通利用する
struct TestStatusBar: View {
    @EnvironmentObject var testViewModel: TestViewModel

    // 中断ボタン
    let stopButtonWidth: CGFloat
    let stopButtonHeight: CGFloat
    let stopButtonFont: Font
    var stopButtonCornerRadius: CGFloat = 8
    var stopButtonTopPadding: CGFloat = 0

    // 次に押す数字
    let numberFontSize: CGFloat
    var numberFontWeight: Font.Weight = .regular
    let numberPlaceholderHeight: CGFloat

    // エラーメッセージ
    let errorFont: Font

    // アクション
    let onStopTapped: () -> Void

    var body: some View {
        Group {
            // 中断ボタン
            Button("Stop") {
                onStopTapped()
            }
            .font(stopButtonFont)
            .foregroundColor(.white)
            .frame(width: stopButtonWidth, height: stopButtonHeight)
            .background(.red)
            .cornerRadius(stopButtonCornerRadius)
            .padding(.top, stopButtonTopPadding)

            // 次に押す数字
            if testViewModel.currentNumber <= testViewModel.targetNumber {
                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text("Next →")
                        .font(.title2)
                    Text("\(testViewModel.currentNumber)")
                        .font(.system(size: numberFontSize, weight: numberFontWeight))
                }
                .lineLimit(1)
                .minimumScaleFactor(0.5)
            } else {
                Text("")
                    .font(.system(size: numberFontSize))
                    .frame(height: numberPlaceholderHeight)
            }

            // エラーメッセージ（領域は常に確保し、表示/非表示はopacityで切り替えてレイアウトシフトを防ぐ）
            Text("Please tap the correct number.")
                .foregroundColor(.red)
                .font(errorFont)
                .multilineTextAlignment(.center)
                .opacity(testViewModel.showError ? 1 : 0)
                .accessibilityHidden(!testViewModel.showError)
        }
    }
}
