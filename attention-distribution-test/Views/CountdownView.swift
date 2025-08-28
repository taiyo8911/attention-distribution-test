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
    @State private var navigateToTest = false
    @Environment(\.dismiss) var dismiss

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
        .onReceive(testViewModel.$shouldReturnToStart) { shouldReturn in
            if shouldReturn {
                navigateToTest = false
                dismiss()
                testViewModel.shouldReturnToStart = false
            }
        }
        .fullScreenCover(isPresented: $navigateToTest) {
            TestView()
                .environmentObject(testViewModel)
        }
    }

    private func startCountdown() {
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            if countdownNumber > 1 {
                countdownNumber -= 1
            } else {
                timer.invalidate()

                // カウントダウン終了後、TestViewに遷移
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    navigateToTest = true
                }
            }
        }
    }
}

#Preview {
    CountdownView()
        .environmentObject(TestViewModel())
}
