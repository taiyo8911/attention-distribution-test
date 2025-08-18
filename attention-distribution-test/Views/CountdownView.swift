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
    @State private var showTestView = false
    @Environment(\.dismiss) var dismiss

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            if showTestView {
                TestView()
                    .environmentObject(testViewModel)
            } else {
                VStack {
                    Spacer()

                    Text("\(countdownNumber)")
                        .font(.system(size: 120, weight: .bold, design: .rounded))
                        .foregroundColor(.white)

                    Spacer()
                }
            }
        }
        .onAppear {
            startCountdown()
        }
    }

    private func startCountdown() {
        testViewModel.startCountdown()

        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            if countdownNumber > 1 {
                countdownNumber -= 1
            } else if countdownNumber == 1 {
                countdownNumber = 0

                // 少し待ってからテスト開始
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    testViewModel.completeCountdown()
                    withAnimation(.easeInOut(duration: 0.3)) {
                        showTestView = true
                    }
                    timer.invalidate()
                }
            }
        }
    }
}

#Preview {
    CountdownView()
        .environmentObject(TestViewModel())
}
