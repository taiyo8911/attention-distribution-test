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
    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack(spacing: 20) {
            // タイマー表示
            Text(formattedTime)
                .font(.title)
                .fontWeight(.semibold)
                .monospacedDigit()

            // 中断ボタン
            Button("検査をやめる") {
                showingStopConfirmation = true
            }
            .foregroundColor(.red)

            // 次に押す数字
            Text("次に押す: \(testViewModel.currentNumber)")
                .font(.headline)

            // エラーメッセージ
            if testViewModel.showError {
                Text("⚠️ 間違いです。正しい数字をタップしてください。")
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }

            // 7x7グリッド
            gridView

            // 確認ボタン
            Button("確認") {
                testViewModel.confirmSelection()
            }
            .font(.title2)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(testViewModel.canConfirm ? .blue : .gray)
            .cornerRadius(12)
            .disabled(!testViewModel.canConfirm)
            .padding(.horizontal)
        }
        .padding()
        .navigationBarHidden(true)
        .fullScreenCover(isPresented: $testViewModel.showingResultView) {
            ResultView()
                .environmentObject(testViewModel)
        }
        .alert("検査を中断しますか？", isPresented: $showingStopConfirmation) {
            Button("中断する", role: .destructive) {
                testViewModel.stopTest()
                dismiss()
            }
            Button("続ける", role: .cancel) { }
        }
    }

    // MARK: - Grid View
    private var gridView: some View {
        GeometryReader { geometry in
            let size = min(geometry.size.width, geometry.size.height)
            let cellSize = size / 7

            LazyVGrid(columns: Array(repeating: GridItem(.fixed(cellSize), spacing: 1), count: 7), spacing: 1) {
                ForEach(0..<7, id: \.self) { row in
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
        .aspectRatio(1, contentMode: .fit)
    }

    // MARK: - Computed Properties
    private var formattedTime: String {
        let minutes = Int(testViewModel.elapsedTime) / 60
        let seconds = Int(testViewModel.elapsedTime) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

#Preview {
    let testViewModel = TestViewModel()
    testViewModel.startTest()

    return TestView()
        .environmentObject(testViewModel)
}
