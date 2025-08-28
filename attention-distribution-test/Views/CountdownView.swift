//
//  CountdownView.swift
//  attention-distribution-test
//
//  Created by Taiyo KOSHIBA on 2025/08/18.
//

import SwiftUI

struct CountdownView: View {
    @EnvironmentObject var testViewModel: TestViewModel
    @State private var countdownNumber = 3
    @State private var countdownTimer: Timer?

    let onComplete: () -> Void

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            Text("\(countdownNumber)")
                .font(.system(size: 120, weight: .bold))
                .foregroundColor(.white)
        }
        .onAppear {
            startCountdown()
        }
        .onDisappear {
            cleanupTimer()
        }
    }

    private func startCountdown() {
        countdownTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            if countdownNumber > 1 {
                countdownNumber -= 1
            } else {
                // カウントダウン完了（「1」を1秒間表示してから遷移）
                timer.invalidate()
                countdownTimer = nil

                // 1秒後に完了コールバックを呼ぶ
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    onComplete()
                }
            }
        }
    }

    private func cleanupTimer() {
        countdownTimer?.invalidate()
        countdownTimer = nil
    }
}

#Preview {
    CountdownView(onComplete: {})
        .environmentObject(TestViewModel())
}
