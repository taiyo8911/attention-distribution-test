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
            VStack(spacing: 16) {
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
                    // 文字サイズは大きめにしたい
                        .font(.system(size: 50))
                } else {
                    Text("")
                        .font(.system(size: 50))
                    // スペース確保
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
                        .frame(height: 20) // エラーメッセージのスペース確保
                }

                // 7x7グリッド
                let availableWidth = geometry.size.width - 32 // 左右パディング16ずつ
                let availableHeight = geometry.size.height - 250 // 上下の要素分を差し引く
                let gridSize = min(availableWidth, availableHeight) // グリッドの正方形サイズ
                let cellSize = (gridSize - 6) / 7 // 境界線6本分(1pt×6)を差し引く

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
                    let completed = testViewModel.confirmSelectionWithResult() // 選択確認と完了チェック
                    // 完了していたら結果画面へ遷移
                    if completed {
                        // 0.5秒後に結果画面へ
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
            .padding()
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
