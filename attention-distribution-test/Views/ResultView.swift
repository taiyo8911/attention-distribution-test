//
//  ResultView.swift
//  attention-distribution-test
//
//  Created by Taiyo KOSHIBA on 2025/08/18.
//

import SwiftUI

struct ResultView: View {
    @EnvironmentObject var testViewModel: TestViewModel

    let onReturnToStart: () -> Void // メイン画面へ戻るコールバック

    var body: some View {
        VStack(spacing: 50) {
            Spacer()

            // タイトル
            Text("検査終了")
                .font(.largeTitle)
                .fontWeight(.bold)

            // 完了時間
            VStack(spacing: 8) {
                Text("完了時間")
                    .font(.title2)
                    .foregroundColor(.secondary)

                Text(testViewModel.elapsedTime.formattedTime)
                    .font(.system(size: 48, weight: .bold, design: .monospaced))
                    .foregroundColor(.blue)
                    .monospacedDigit()
            }

            // メインへ戻るボタン
            Button("メイン画面へ戻る") {
                onReturnToStart()
            }
            .font(.title3)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(.blue)
            .cornerRadius(12)
            .padding(.horizontal, 20)

            Spacer()
        }
        .toolbar(.hidden, for: .navigationBar)
        .dynamicTypeSize(...DynamicTypeSize.accessibility2)
    }
}

#Preview {
    let testViewModel = TestViewModel(
        timerService: MockTimerService(),
        dataService: MockDataService()
    )

    return ResultView(onReturnToStart: {})
        .environmentObject(testViewModel)
}
