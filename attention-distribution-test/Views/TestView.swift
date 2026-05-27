//
//  TestView.swift
//  attention-distribution-test
//
//  Created by Taiyo KOSHIBA on 2025/08/18.
//

import SwiftUI
import UIKit

struct TestView: View {
    @EnvironmentObject var testViewModel: TestViewModel
    @Environment(\.scenePhase) private var scenePhase // バックグラウンド復帰を検知
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
        // バックグラウンド復帰時にタイマーを即座に同期
        .onChange(of: scenePhase) { newPhase in
            if newPhase == .active {
                testViewModel.refreshTimer()
            }
        }
        // やめるボタン押下時の確認アラート
        .alert("Stop the test?", isPresented: $showingStopConfirmation) {
            Button("Stop", role: .destructive) {
                testViewModel.stopTest()
                onCancel()
            }
            Button("Continue", role: .cancel) { }
        }
        .dynamicTypeSize(...DynamicTypeSize.accessibility1)
    }

    // 確認ボタンタップ時の処理（縦・横レイアウト共通）
    private func confirmAction() {
        let completed = testViewModel.confirmSelectionWithResult()

        // 誤答時はハプティックフィードバック
        if testViewModel.showError {
            UINotificationFeedbackGenerator().notificationOccurred(.error)
        }

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
