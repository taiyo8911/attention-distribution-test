//
//  LandscapeTestLayout.swift
//  attention-distribution-test
//
//  Created by Taiyo KOSHIBA on 2025/08/18.
//

import SwiftUI

// 横向き（ランドスケープ）の検査画面レイアウト
struct LandscapeTestLayout: View {
    @EnvironmentObject var testViewModel: TestViewModel
    let geometry: GeometryProxy
    let onStopTapped: () -> Void
    let onConfirmTapped: () -> Void

    var body: some View {
        let gridDimension = CGFloat(testViewModel.gridSize)
        let availableWidth = geometry.size.width - 160 - 60
        let availableHeight = geometry.size.height - 100
        let totalGridSize = min(availableWidth, availableHeight)
        let cellSize = (totalGridSize - (gridDimension - 1)) / gridDimension

        HStack(spacing: 20) {
            // 左側: ステータスバー（中断ボタン、現在の数字、エラーメッセージ）
            VStack(spacing: 4) {
                TestStatusBar(
                    stopButtonWidth: 100,
                    stopButtonHeight: 40,
                    stopButtonFont: .body,
                    stopButtonCornerRadius: 12,
                    numberFontSize: 36,
                    numberPlaceholderHeight: 40,
                    errorFont: .caption,
                    errorPlaceholderHeight: 15,
                    onStopTapped: onStopTapped
                )

                Spacer()
            }
            .frame(width: 160)
            .padding(.vertical)

            // 右側: グリッドエリア + 確認ボタン
            VStack(spacing: 10) {
                GridBoard(cellSize: cellSize)

                ConfirmButton(isCompact: false, action: onConfirmTapped)
            }

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
}
