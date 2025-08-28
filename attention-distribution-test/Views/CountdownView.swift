//
//  CountdownView.swift
//  attention-distribution-test
//
//  Created by Taiyo KOSHIBA on 2025/08/18.
//

import SwiftUI

struct CountdownView: View {
    @EnvironmentObject var testViewModel: TestViewModel
    @State private var countdownNumber = 3 // カウントダウンの開始数
    @State private var countdownTimer: Timer? // タイマー用の変数

    let onComplete: () -> Void // カウントダウン完了時のコールバック

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            Text("\(countdownNumber)")
                .font(.system(size: 120, weight: .bold))
                .foregroundColor(.white)
        }
        // 画面表示時にカウントダウン開始
        .onAppear {
            startCountdown()
        }
        // 画面離脱時にタイマー停止
        .onDisappear {
            cleanupTimer()
        }
    }

    // カウントダウン
    private func startCountdown() {
        // 1秒ごとに繰り返し
        countdownTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            if countdownNumber > 1 {
                countdownNumber -= 1
            } else {
                timer.invalidate() // タイマー停止
                countdownTimer = nil // タイマー変数をクリア

                // ユーザーが数字を認識できるように少し待機して完了コールバックを呼び出す
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    onComplete()
                }
            }
        }
    }

    // タイマーを停止してクリア
    private func cleanupTimer() {
        countdownTimer?.invalidate()
        countdownTimer = nil
    }
}

#Preview {
    CountdownView(onComplete: {})
        .environmentObject(TestViewModel())
}
