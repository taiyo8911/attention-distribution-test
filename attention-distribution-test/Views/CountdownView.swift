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

    let onComplete: () -> Void // カウントダウン完了時のコールバック

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            Text("\(countdownNumber)")
                .font(.system(size: 120, weight: .bold))
                .foregroundColor(.white)
        }
        // 画面表示中だけカウントダウンを走らせる（離脱時は自動キャンセル）
        .task {
            await runCountdown()
        }
    }

    // カウントダウン処理
    private func runCountdown() async {
        while countdownNumber > 1 {
            try? await Task.sleep(for: .seconds(1))
            if Task.isCancelled { return }
            countdownNumber -= 1
        }

        // 最後の数字を認識できるように少し待機してから完了コールバックを呼ぶ
        try? await Task.sleep(for: .seconds(1))
        if Task.isCancelled { return }
        try? await Task.sleep(for: .milliseconds(100))
        if Task.isCancelled { return }
        onComplete()
    }
}

#Preview {
    CountdownView(onComplete: {})
        .environmentObject(TestViewModel())
}
