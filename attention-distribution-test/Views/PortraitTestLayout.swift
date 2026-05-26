//
//  PortraitTestLayout.swift
//  attention-distribution-test
//
//  Created by Taiyo KOSHIBA on 2025/08/18.
//

import SwiftUI

// 縦向き（ポートレート）の検査画面レイアウト
struct PortraitTestLayout: View {
    @EnvironmentObject var testViewModel: TestViewModel
    let geometry: GeometryProxy
    let isSmallScreen: Bool
    let onStopTapped: () -> Void
    let onConfirmTapped: () -> Void

    var body: some View {
        let metrics = Metrics(
            geometry: geometry,
            isSmallScreen: isSmallScreen,
            gridDimension: testViewModel.gridSize
        )

        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: metrics.baseSpacing) {
                // タイマー
                Text(testViewModel.elapsedTime.formattedTime)
                    .font(.system(size: metrics.timerFontSize, weight: .bold, design: .monospaced))
                    .monospacedDigit()
                    .padding(.top, metrics.topPadding)

                // 中断ボタン
                Button("やめる") {
                    onStopTapped()
                }
                .font(isSmallScreen ? .callout : .title2)
                .foregroundColor(.white)
                .frame(width: metrics.stopButtonWidth, height: metrics.stopButtonHeight)
                .background(.red)
                .cornerRadius(8)

                // 次に押す数字
                if testViewModel.currentNumber <= testViewModel.targetNumber {
                    Text("\(testViewModel.currentNumber)")
                        .font(.system(size: metrics.numberFontSize, weight: .semibold))
                } else {
                    Text("")
                        .font(.system(size: metrics.numberFontSize))
                        .frame(height: metrics.numberFontSize)
                }

                // エラーメッセージ
                Group {
                    if testViewModel.showError {
                        Text("正しい数字をタップしてください")
                            .foregroundColor(.red)
                            .font(isSmallScreen ? .caption : .subheadline)
                    } else {
                        Text("")
                            .font(isSmallScreen ? .caption : .subheadline)
                            .frame(height: 16)
                    }
                }

                // グリッド
                GridBoard(cellSize: metrics.cellSize)
                    .padding(.vertical, metrics.baseSpacing)

                // 確認ボタン
                ConfirmButton(isCompact: isSmallScreen, action: onConfirmTapped)
                    .frame(height: metrics.confirmButtonHeight)

                // 下部余白（小画面では少なく）
                Spacer()
                    .frame(height: metrics.bottomSpacerHeight)
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 16)
        }
    }
}

// MARK: - Metrics
extension PortraitTestLayout {
    // 縦向きレイアウトのサイズ・余白を一括計算するヘルパー
    struct Metrics {
        let timerFontSize: CGFloat
        let numberFontSize: CGFloat
        let stopButtonWidth: CGFloat
        let stopButtonHeight: CGFloat
        let confirmButtonHeight: CGFloat
        let baseSpacing: CGFloat
        let topPadding: CGFloat
        let bottomSpacerHeight: CGFloat
        let totalGridSize: CGFloat
        let cellSize: CGFloat

        init(geometry: GeometryProxy, isSmallScreen: Bool, gridDimension: Int) {
            // 小画面用の調整値
            self.timerFontSize = isSmallScreen ? 24 : 32
            self.numberFontSize = isSmallScreen ? 36 : 50
            self.stopButtonWidth = isSmallScreen ? 80 : 120
            self.stopButtonHeight = isSmallScreen ? 32 : 40
            self.confirmButtonHeight = isSmallScreen ? 44 : 60
            self.baseSpacing = isSmallScreen ? 6 : 16
            self.topPadding = isSmallScreen ? 8 : 16
            self.bottomSpacerHeight = isSmallScreen ? 8 : 16

            // グリッド以外で確保しておく縦方向のサイズ
            let reservedHeight: CGFloat =
                timerFontSize + 10 +                              // タイマー
                stopButtonHeight + baseSpacing +                  // 中断ボタン
                numberFontSize + baseSpacing +                    // 次の数字
                20 + baseSpacing +                                // エラーメッセージ領域
                confirmButtonHeight + baseSpacing +               // 確認ボタン
                60                                                // 上下余白

            let availableGridHeight = geometry.size.height - reservedHeight
            let availableGridWidth = geometry.size.width - 32 // 左右パディング

            // グリッドサイズの計算（最小サイズを保証）
            let dim = CGFloat(gridDimension)
            let maxGridSize = min(availableGridWidth, availableGridHeight)
            let minGridSize: CGFloat = isSmallScreen ? 280 : 320
            self.totalGridSize = max(minGridSize, maxGridSize)
            self.cellSize = max(35, (totalGridSize - (dim - 1)) / dim) // 最小セルサイズ35px
        }
    }
}
