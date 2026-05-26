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
            let isLandscape = geometry.size.width > geometry.size.height
            let isSmallScreen = geometry.size.height < 700 // iPhone SE (667) や小さい画面を判定

            if isLandscape {
                landscapeLayout(geometry: geometry)
            } else {
                PortraitTestLayout(
                    geometry: geometry,
                    isSmallScreen: isSmallScreen,
                    onStopTapped: { showingStopConfirmation = true },
                    onConfirmTapped: confirmAction
                )
            }
        }
        .toolbar(.hidden, for: .navigationBar)
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
        .dynamicTypeSize(...DynamicTypeSize.accessibility1)
    }

    // 確認ボタンタップ時の処理（縦・横レイアウト共通）
    private func confirmAction() {
        let completed = testViewModel.confirmSelectionWithResult()
        if completed {
            Task {
                try? await Task.sleep(for: .milliseconds(500))
                onComplete()
            }
        }
    }

    // MARK: - 横向きレイアウト
    private func landscapeLayout(geometry: GeometryProxy) -> some View {
        HStack(spacing: 20) {
            // 左側: コントロールエリア
            VStack(spacing: 4) {
                // タイマー
                Text(testViewModel.elapsedTime.formattedTime)
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
                if testViewModel.currentNumber <= testViewModel.targetNumber {
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
                let gridDimension = CGFloat(testViewModel.gridSize)
                let availableWidth = geometry.size.width - 160 - 60
                let availableHeight = geometry.size.height - 100
                let totalGridSize = min(availableWidth, availableHeight)
                let cellSize = (totalGridSize - (gridDimension - 1)) / gridDimension

                GridBoard(cellSize: cellSize)

                ConfirmButton(isCompact: false, action: confirmAction)
            }

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
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
