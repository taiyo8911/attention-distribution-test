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
            let isSmallScreen = geometry.size.height < 700 // iPhone SE (667) や小さい画面を判定

            if isLandscape {
                LandscapeTestLayout(
                    geometry: geometry,
                    onStopTapped: { showingStopConfirmation = true },
                    onConfirmTapped: confirmAction
                )
            } else {
                PortraitTestLayout(
                    geometry: geometry,
                    isSmallScreen: isSmallScreen,
                    onStopTapped: { showingStopConfirmation = true },
                    onConfirmTapped: confirmAction
                )
            }
        }
        .toolbar(.hidden, for: .navigationBar)
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
        .dynamicTypeSize(...DynamicTypeSize.accessibility1)
    }

    // 確認ボタンタップ時の処理（縦・横レイアウト共通）
    private func confirmAction() {
        let completed = testViewModel.confirmSelectionWithResult()
        if completed {
            Task {
                try? await Task.sleep(for: .milliseconds(500))
                onComplete()
            }
        }
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
