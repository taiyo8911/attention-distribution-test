//
//  TestView.swift
//  attention-distribution-test
//
//  Created by Taiyo KOSHIBA on 2025/08/18.
//


import SwiftUI

struct TestView: View {
    @EnvironmentObject var testManager: TestManager
    @State private var showingStopConfirmation = false
    @State private var showResultView = false
    @Environment(\.dismiss) var dismiss

    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                // ヘッダー部分
                headerSection

                // メインコンテンツ
                mainContentSection(geometry: geometry)

                // フッター部分
                footerSection
            }
        }
        .navigationBarHidden(true)
        .onChange(of: testManager.currentNumber) { newValue in
            if newValue > 48 {
                showResultView = true
            }
        }
        .fullScreenCover(isPresented: $showResultView) {
            ResultView()
                .environmentObject(testManager)
        }
        .alert("検査を中断しますか？", isPresented: $showingStopConfirmation) {
            Button("YES") {
                testManager.stopTest()
                dismiss()
            }
            Button("NO", role: .cancel) { }
        }
    }

    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: 12) {
            // タイマー
            Text(testManager.elapsedTime.formattedTime)
                .font(.title)
                .fontWeight(.bold)
                .monospacedDigit()

            // 中断ボタン
            Button(action: {
                showingStopConfirmation = true
            }) {
                Text("検査をやめる")
                    .font(.caption)
                    .foregroundColor(.red)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.red.opacity(0.1))
                    .cornerRadius(8)
            }

            // 次に押す数字
            Text("次に押す: \(testManager.currentNumber)")
                .font(.headline)
                .fontWeight(.semibold)

            // エラーメッセージ
            if testManager.showError {
                VStack(alignment: .leading, spacing: 2) {
                    Text("⚠️ 間違いです。")
                        .foregroundColor(.red)
                        .font(.caption)
                    Text("正しい数字をタップしてください。")
                        .foregroundColor(.red)
                        .font(.caption)
                }
                .transition(.opacity)
                .animation(.easeInOut(duration: 0.3), value: testManager.showError)
            }
        }
        .padding(.vertical, 12)
        .background(Color(.systemBackground))
    }

    // MARK: - Main Content Section
    private func mainContentSection(geometry: GeometryProxy) -> some View {
        let availableHeight = geometry.size.height - 160 // ヘッダーとフッターを除く
        let gridSize = min(geometry.size.width - 32, availableHeight)
        let cellSize = gridSize / 7

        return VStack {
            Spacer()

            // 7x7 グリッド
            VStack(spacing: 1) {
                ForEach(0..<7, id: \.self) { row in
                    HStack(spacing: 1) {
                        ForEach(0..<7, id: \.self) { col in
                            GridCell(
                                number: testManager.gridNumbers[row][col],
                                isSelected: testManager.selectedPosition?.0 == row && testManager.selectedPosition?.1 == col,
                                cellSize: cellSize
                            ) {
                                let _ = testManager.selectNumber(at: row, col: col)
                            }
                        }
                    }
                }
            }
            .background(Color.black)
            .cornerRadius(2)

            Spacer()
        }
    }

    // MARK: - Footer Section
    private var footerSection: some View {
        VStack {
            Button(action: {
                testManager.confirmSelection()
            }) {
                Text("確認")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(testManager.selectedPosition != nil ? Color.blue : Color.gray)
                    .cornerRadius(12)
            }
            .disabled(testManager.selectedPosition == nil)
            .padding(.horizontal, 40)
            .padding(.bottom, 20)
        }
    }
}

// MARK: - Grid Cell Component
struct GridCell: View {
    let number: Int
    let isSelected: Bool
    let cellSize: CGFloat
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text("\(number)")
                .font(.system(size: fontSize, weight: .bold, design: .rounded))
                .foregroundColor(.black)
                .frame(width: cellSize, height: cellSize)
                .background(backgroundColor)
                .overlay(
                    Rectangle()
                        .stroke(Color.black, lineWidth: 1)
                )
        }
        .buttonStyle(PlainButtonStyle())
    }

    private var fontSize: CGFloat {
        cellSize * 0.5
    }

    private var backgroundColor: Color {
        if isSelected {
            return Color.yellow.opacity(0.7)
        } else {
            return Color.white
        }
    }
}

#Preview {
    let testManager = TestManager()
    testManager.startTest() // プレビュー用にテストを開始状態にする

    return TestView()
        .environmentObject(testManager)
}
