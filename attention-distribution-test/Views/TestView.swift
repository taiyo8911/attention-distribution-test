//
//  TestView.swift
//  attention-distribution-test
//
//  Created by Taiyo KOSHIBA on 2025/08/18.
//

import SwiftUI

struct TestView: View {
    @EnvironmentObject var testViewModel: TestViewModel
    @State private var showingStopConfirmation = false

    let onComplete: () -> Void
    let onCancel: () -> Void

    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 16) {
                // タイマー
                Text(formattedTime)
                    .font(.system(size: 32, weight: .bold, design: .monospaced))
                    .monospacedDigit()
                    .padding(12)

                // 中断ボタン
                Button("やめる") {
                    showingStopConfirmation = true
                }
                .font(.title3)
                .foregroundColor(.white)
                .frame(width: 120)
                .padding(12)
                .background(.red)
                .cornerRadius(12)

                // 次に押す数字
                if testViewModel.currentNumber <= 48 {
                    Text("次に押す: \(testViewModel.currentNumber)")
                        .font(.headline)
                } else {
                    Text("")
                        .font(.headline)
                        .frame(height: 20) // スペース確保
                }

                // エラーメッセージ
                if testViewModel.showError {
                    Text("正しい数字をタップしてください")
                        .foregroundColor(.red)
                        .font(.headline)
                        .multilineTextAlignment(.center)
                        .padding(12)
                } else {
                    Text("")
                        .font(.headline)
                        .frame(height: 20) // エラーメッセージのスペース確保
                        .padding(12)
                }

                // 7x7グリッド
                let availableWidth = geometry.size.width - 32 // 左右パディング16ずつ
                let availableHeight = geometry.size.height - 250 // 上下の要素分を差し引く
                let gridSize = min(availableWidth, availableHeight)
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
                    let completed = testViewModel.confirmSelectionWithResult()
                    if completed {
                        // 0.5秒後に結果画面へ
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            onComplete()
                        }
                    }
                }) {
                    Text("確認")
                        .font(.title2)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, maxHeight: 100)
                }
                .background(testViewModel.canConfirm ? .blue : .gray)
                .cornerRadius(12)
                .disabled(!testViewModel.canConfirm)

                Spacer()
            }
            .padding()
        }
        .navigationBarHidden(true)
        .onAppear {
            testViewModel.startTest()
        }
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
