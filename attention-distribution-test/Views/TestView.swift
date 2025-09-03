//
//  TestView.swift
//  attention-distribution-test
//
//  Created by Taiyo KOSHIBA on 2025/08/18.
//

import SwiftUI

struct TestView: View {
    @EnvironmentObject var testViewModel: TestViewModel
    @State private var showingStopConfirmation = false // 中断確認アラート用の変数

    let onComplete: () -> Void // 検査完了時のコールバック
    let onCancel: () -> Void // 検査中断時のコールバック

    var body: some View {
        GeometryReader { geometry in
            let screenHeight = geometry.size.height
            let screenWidth = geometry.size.width
            let isLandscape = screenWidth > screenHeight
            let isSmallScreen = screenHeight < 700 // iPhone SE (667) や小さい画面を判定

            if isLandscape {
                landscapeLayout(geometry: geometry)
            } else {
                portraitLayout(geometry: geometry, isSmallScreen: isSmallScreen)
            }
        }
        .navigationBarHidden(true)
        // 画面表示時に検査開始
        .onAppear {
            testViewModel.startTest()
        }
        // やめるボタン押下時の確認アラート
        .alert("検査を中断しますか？", isPresented: $showingStopConfirmation) {
            Button("中断する", role: .destructive) {
                testViewModel.stopTest()
                onCancel()
            }
            Button("続ける", role: .cancel) { }
        }
    }

    // MARK: - 横向きレイアウト
    private func landscapeLayout(geometry: GeometryProxy) -> some View {
        HStack(spacing: 20) {
            // 左側: コントロールエリア
            VStack(spacing: 4) {
                // タイマー
                Text(formattedTime)
                    .font(.system(size: 24, weight: .bold, design: .monospaced))
                    .monospacedDigit()

                // 中断ボタン
                Button("やめる") {
                    showingStopConfirmation = true
                }
                .font(.body)
                .foregroundColor(.white)
                .frame(width: 100, height: 40)
                .background(.red)
                .cornerRadius(12)

                // 次に押す数字
                if testViewModel.currentNumber <= 48 {
                    Text("\(testViewModel.currentNumber)")
                        .font(.system(size: 36))
                } else {
                    Text("")
                        .font(.system(size: 36))
                        .frame(height: 40)
                }

                // エラーメッセージ
                if testViewModel.showError {
                    Text("正しい数字をタップしてください")
                        .foregroundColor(.red)
                        .font(.caption)
                        .multilineTextAlignment(.center)
                } else {
                    Text("")
                        .font(.caption)
                        .frame(height: 15)
                }

                Spacer()
            }
            .frame(width: 160)
            .padding(.vertical)

            // 右側: グリッドエリア + 確認ボタン
            VStack(spacing: 10) {
                let availableWidth = geometry.size.width - 160 - 60
                let availableHeight = geometry.size.height - 100
                let gridSize = min(availableWidth, availableHeight)
                let cellSize = (gridSize - 6) / 7

                gridView(cellSize: cellSize, gridSize: gridSize)

                // 確認ボタン
                confirmButton(isCompact: false)
            }

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }

    // MARK: - 縦向きレイアウト（小画面対応）
    private func portraitLayout(geometry: GeometryProxy, isSmallScreen: Bool) -> some View {
        let screenHeight = geometry.size.height
        let screenWidth = geometry.size.width

        // 小画面用の調整値
        let timerFontSize: CGFloat = isSmallScreen ? 24 : 32
        let numberFontSize: CGFloat = isSmallScreen ? 36 : 50
        let stopButtonHeight: CGFloat = isSmallScreen ? 32 : 40
        let confirmButtonHeight: CGFloat = isSmallScreen ? 44 : 60
        let baseSpacing: CGFloat = isSmallScreen ? 6 : 16

        // レイアウト計算
        let reservedHeight: CGFloat =
            timerFontSize + 10 + // タイマー
            stopButtonHeight + baseSpacing + // 中断ボタン
            numberFontSize + baseSpacing + // 次の数字
            20 + baseSpacing + // エラーメッセージ領域
            confirmButtonHeight + baseSpacing + // 確認ボタン
            60 // 上下余白

        let availableGridHeight = screenHeight - reservedHeight
        let availableGridWidth = screenWidth - 32 // 左右パディング

        // グリッドサイズの計算（最小サイズを保証）
        let maxGridSize = min(availableGridWidth, availableGridHeight)
        let minGridSize: CGFloat = isSmallScreen ? 280 : 320 // 最小グリッドサイズ
        let gridSize = max(minGridSize, maxGridSize)
        let cellSize = max(35, (gridSize - 6) / 7) // 最小セルサイズ35px

        return ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: baseSpacing) {
                // タイマー
                Text(formattedTime)
                    .font(.system(size: timerFontSize, weight: .bold, design: .monospaced))
                    .monospacedDigit()
                    .padding(.top, isSmallScreen ? 8 : 16)

                // 中断ボタン
                Button("やめる") {
                    showingStopConfirmation = true
                }
                .font(isSmallScreen ? .callout : .title2)
                .foregroundColor(.white)
                .frame(width: isSmallScreen ? 80 : 120, height: stopButtonHeight)
                .background(.red)
                .cornerRadius(8)

                // 次に押す数字
                if testViewModel.currentNumber <= 48 {
                    Text("\(testViewModel.currentNumber)")
                        .font(.system(size: numberFontSize, weight: .semibold))
                } else {
                    Text("")
                        .font(.system(size: numberFontSize))
                        .frame(height: numberFontSize)
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

                // 7x7グリッド
                gridView(cellSize: cellSize, gridSize: gridSize)
                    .padding(.vertical, baseSpacing)

                // 確認ボタン
                confirmButton(isCompact: isSmallScreen)
                    .frame(height: confirmButtonHeight)

                // 下部余白（小画面では少なく）
                Spacer()
                    .frame(height: isSmallScreen ? 8 : 16)
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 16)
        }
    }

    // MARK: - グリッドビュー
    private func gridView(cellSize: CGFloat, gridSize: CGFloat) -> some View {
        VStack(spacing: 1) {
            ForEach(0..<7, id: \.self) { row in
                HStack(spacing: 1) {
                    ForEach(0..<7, id: \.self) { col in
                        GridCell(
                            number: testViewModel.getNumber(at: row, col: col),
                            isSelected: testViewModel.isSelected(row: row, col: col),
                            cellSize: cellSize
                        ) {
                            testViewModel.tapNumber(at: row, col: col)
                        }
                    }
                }
            }
        }
        .frame(width: cellSize * 7 + 6, height: cellSize * 7 + 6)
        .background(Color.clear)
    }

    // MARK: - 確認ボタン
    private func confirmButton(isCompact: Bool) -> some View {
        Button(action: {
            let completed = testViewModel.confirmSelectionWithResult()
            if completed {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    onComplete()
                }
            }
        }) {
            Text("確認")
                .font(isCompact ? .title3 : .title2)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .frame(maxWidth: isCompact ? 280 : 400)
                .frame(height: isCompact ? 44 : 60)
        }
        .background(testViewModel.canConfirm ? .blue : .gray)
        .cornerRadius(isCompact ? 8 : 12)
        .disabled(!testViewModel.canConfirm)
    }

    // タイマー用のフォーマットされた時間文字列
    private var formattedTime: String {
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

    return TestView(onComplete: {}, onCancel: {})
        .environmentObject(testViewModel)
}
