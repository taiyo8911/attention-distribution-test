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
            let dynamicSpacing: CGFloat = isLandscape ? 4 : 16  // 横向きでは間隔をさらに狭く

            if isLandscape {
                // 横向きレイアウト: 2列構成
                HStack(spacing: 20) {
                    // 左側: コントロールエリア
                    VStack(spacing: dynamicSpacing) {
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
                        let availableWidth = geometry.size.width - 160 - 60  // 左側エリア、パディング、余白
                        let availableHeight = geometry.size.height - 100  // 上下余白 + 確認ボタン領域
                        let gridSize = min(availableWidth, availableHeight)
                        let cellSize = (gridSize - 6) / 7

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
                        .frame(width: gridSize, height: gridSize)
                        .background(Color.clear)

                        // 確認ボタン（グリッドの下）
                        Button(action: {
                            let completed = testViewModel.confirmSelectionWithResult()
                            if completed {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                    onComplete()
                                }
                            }
                        }) {
                            Text("確認")
                                .font(.title2)
                                .foregroundColor(.white)
                                .frame(width: 500, height: 50)
                        }
                        .background(testViewModel.canConfirm ? .blue : .gray)
                        .cornerRadius(12)
                        .disabled(!testViewModel.canConfirm)
                    }

                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding()
            } else {
                // 縦向きレイアウト: 従来の縦並び
                VStack(spacing: dynamicSpacing) {
                    // タイマー
                    Text(formattedTime)
                        .font(.system(size: 32, weight: .bold, design: .monospaced))
                        .monospacedDigit()

                    // 中断ボタン
                    Button("やめる") {
                        showingStopConfirmation = true
                    }
                    .font(.title2)
                    .foregroundColor(.white)
                    .frame(width: 120)
                    .padding(10)
                    .background(.red)
                    .cornerRadius(12)

                    // 次に押す数字
                    if testViewModel.currentNumber <= 48 {
                        Text("\(testViewModel.currentNumber)")
                            .font(.system(size: 50))
                    } else {
                        Text("")
                            .font(.system(size: 50))
                            .frame(height: 60)
                    }

                    // エラーメッセージ
                    if testViewModel.showError {
                        Text("正しい数字をタップしてください")
                            .foregroundColor(.red)
                            .font(.headline)
                    } else {
                        Text("")
                            .font(.headline)
                            .frame(height: 20)
                    }

                    // 7x7グリッド
                    let availableWidth = geometry.size.width - 32
                    let availableHeight = geometry.size.height - 250
                    let gridSize = min(availableWidth, availableHeight)
                    let cellSize = (gridSize - 6) / 7

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
                    .frame(width: gridSize, height: gridSize)
                    .background(Color.clear)

                    Spacer()

                    // 確認ボタン
                    Button(action: {
                        let completed = testViewModel.confirmSelectionWithResult()
                        if completed {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                onComplete()
                            }
                        }
                    }) {
                        Text("確認")
                            .font(.title)
                            .foregroundColor(.white)
                            .frame(maxWidth: 500, maxHeight: 100)
                    }
                    .background(testViewModel.canConfirm ? .blue : .gray)
                    .cornerRadius(12)
                    .disabled(!testViewModel.canConfirm)

                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding()
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
