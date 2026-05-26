//
//  CountdownView.swift
//  attention-distribution-test
//
//  Created by Taiyo KOSHIBA on 2025/08/18.
//

import SwiftUI

struct CountdownView: View {
    @EnvironmentObject var testViewModel: TestViewModel
    @State private var displayText = "3" // 表示するテキスト（数字または「始め」）

    let onComplete: () -> Void // カウントダウン完了時のコールバック

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            Text(displayText)
                .font(.system(size: 120, weight: .bold))
                .foregroundColor(.white)
        }
        // 画面表示中だけカウントダウンを走らせる（離脱時は自動キャンセル）
        .task {
            await runCountdown()
        }
    }

    // カウントダウン処理（3→2→1→始め→検査開始）
    private func runCountdown() async {
        for number in [3, 2, 1] {
            displayText = "\(number)"
            try? await Task.sleep(for: .seconds(1))
            if Task.isCancelled { return }
        }

        // 「始め」を表示
        displayText = "始め"
        try? await Task.sleep(for: .seconds(1))
        if Task.isCancelled { return }

        onComplete()
    }
}

#Preview {
    CountdownView(onComplete: {})
        .environmentObject(TestViewModel())
}
