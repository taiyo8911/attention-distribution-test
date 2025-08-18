//
//  CountdownView.swift
//  attention-distribution-test
//
//  Created by Taiyo KOSHIBA on 2025/08/18.
//

import SwiftUI

struct CountdownView: View {
    @EnvironmentObject var testViewModel: TestViewModel
    @Environment(\.dismiss) var dismiss

    @State private var countdownNumber = 3
    @State private var showTestView = false
    @State private var isAnimating = false
    @State private var showReadyMessage = false

    var body: some View {
        ZStack {
            // Background
            backgroundView

            if showTestView {
                // Test view
                TestView()
                    .environmentObject(testViewModel)
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing).combined(with: .opacity),
                        removal: .move(edge: .leading).combined(with: .opacity)
                    ))
            } else {
                // Countdown content
                countdownContent
            }
        }
        .onAppear {
            startCountdown()
        }
        .onDisappear {
            // Cleanup if needed
        }
    }

    // MARK: - Background View
    private var backgroundView: some View {
        ZStack {
            // Gradient background
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.black,
                    Color.black.opacity(0.8),
                    Color.blue.opacity(0.2)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            // Animated particles effect
            ForEach(0..<20, id: \.self) { index in
                Circle()
                    .fill(Color.white.opacity(0.1))
                    .frame(width: CGFloat.random(in: 2...6))
                    .position(
                        x: CGFloat.random(in: 0...UIScreen.main.bounds.width),
                        y: CGFloat.random(in: 0...UIScreen.main.bounds.height)
                    )
                    .scaleEffect(isAnimating ? 1.5 : 0.5)
                    .opacity(isAnimating ? 0.8 : 0.2)
                    .animation(
                        Animation.easeInOut(duration: Double.random(in: 2...4))
                            .repeatForever(autoreverses: true)
                            .delay(Double.random(in: 0...2)),
                        value: isAnimating
                    )
            }
        }
    }

    // MARK: - Countdown Content
    private var countdownContent: some View {
        VStack(spacing: 60) {
            Spacer()

            // Title
            VStack(spacing: 16) {
                Text("準備してください")
                    .font(.title2)
                    .fontWeight(.medium)
                    .foregroundColor(.white.opacity(0.8))

                Text("数字を0から順番にタップします")
                    .font(.callout)
                    .foregroundColor(.white.opacity(0.6))
            }
            .opacity(countdownNumber > 0 ? 1.0 : 0.0)
            .animation(.easeInOut(duration: 0.5), value: countdownNumber)

            // Countdown number or ready message
            ZStack {
                if showReadyMessage {
                    readyMessage
                } else {
                    countdownNumberView
                }
            }

            Spacer()

            // Cancel button
            cancelButton
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.0)) {
                isAnimating = true
            }
        }
    }

    private var countdownNumberView: some View {
        ZStack {
            // Outer ring
            Circle()
                .stroke(Color.white.opacity(0.2), lineWidth: 4)
                .frame(width: 200, height: 200)

            // Progress ring
            Circle()
                .trim(from: 0, to: CGFloat(4 - countdownNumber) / 3)
                .stroke(
                    Color.blue,
                    style: StrokeStyle(lineWidth: 8, lineCap: .round)
                )
                .frame(width: 200, height: 200)
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 1.0), value: countdownNumber)

            // Number
            Text("\(countdownNumber)")
                .font(.system(size: 100, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .scaleEffect(countdownNumber > 0 ? 1.0 : 0.3)
                .opacity(countdownNumber > 0 ? 1.0 : 0.0)
                .animation(
                    .spring(response: 0.6, dampingFraction: 0.8),
                    value: countdownNumber
                )
        }
    }

    private var readyMessage: some View {
        VStack(spacing: 20) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(.green)
                .scaleEffect(showReadyMessage ? 1.0 : 0.3)
                .animation(.spring(response: 0.6, dampingFraction: 0.6), value: showReadyMessage)

            Text("開始！")
                .font(.system(size: 40, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .opacity(showReadyMessage ? 1.0 : 0.0)
                .animation(.easeInOut(duration: 0.3).delay(0.2), value: showReadyMessage)
        }
    }

    private var cancelButton: some View {
        Button(action: {
            dismiss()
        }) {
            HStack {
                Image(systemName: "xmark")
                Text("キャンセル")
            }
            .font(.callout)
//            .fontWeight(.medium)
            .foregroundColor(.white.opacity(0.8))
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(Color.white.opacity(0.1))
            .cornerRadius(20)
        }
        .opacity(countdownNumber > 0 ? 1.0 : 0.0)
        .animation(.easeInOut(duration: 0.3), value: countdownNumber)
    }

    // MARK: - Methods
    private func startCountdown() {
        // Update game state
        testViewModel.startCountdown()

        // Start countdown timer
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            if countdownNumber > 1 {
                // Haptic feedback
                let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                impactFeedback.impactOccurred()

                countdownNumber -= 1
            } else if countdownNumber == 1 {
                // Final countdown
                let impactFeedback = UIImpactFeedbackGenerator(style: .heavy)
                impactFeedback.impactOccurred()

                countdownNumber = 0
                showReadyMessage = true

                // Transition to test after brief delay
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                    startTest()
                    timer.invalidate()
                }
            }
        }
    }

    private func startTest() {
        // Start the actual test
        testViewModel.completeCountdown()

        // Success haptic
        let notificationFeedback = UINotificationFeedbackGenerator()
        notificationFeedback.notificationOccurred(.success)

        // Transition to test view
        withAnimation(.easeInOut(duration: 0.4)) {
            showTestView = true
        }
    }
}

#Preview {
    CountdownView()
        .environmentObject(TestViewModel(
            timerService: MockTimerService(),
            dataService: MockDataService()
        ))
}
