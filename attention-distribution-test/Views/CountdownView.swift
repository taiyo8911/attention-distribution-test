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
                Text("\(countdownNumber)")
                    .font(.system(size: 120, weight: .bold))
                    .foregroundColor(.white)
            }
        }
        .onAppear {
            startCountdown()
        }
        .onReceive(testViewModel.$shouldReturnToStart) { shouldReturn in
            if shouldReturn {
                showTestView = false
                dismiss()
                testViewModel.shouldReturnToStart = false
            }
        }
    }

    private func startCountdown() {
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            if countdownNumber > 1 {
                countdownNumber -= 1
            } else {
                timer.invalidate()

                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    showTestView = true
                }
            }
        }
    }
}

#Preview {
    CountdownView()
        .environmentObject(TestViewModel())
}
