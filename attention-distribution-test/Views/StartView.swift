//
//  StartView.swift
//  attention-distribution-test
//
//  Created by Taiyo KOSHIBA on 2025/08/18.
//

import SwiftUI

// 画面の状態を管理する列挙型
enum AppScreenState {
    case start
    case countdown
    case test
    case result
}

struct StartView: View {
    @EnvironmentObject var testViewModel: TestViewModel
    @EnvironmentObject var historyViewModel: HistoryViewModel

    @State private var showingConfirmation = false // 検査開始確認アラート用の変数
    @State private var showingHistory = false // 履歴表示用の変数
    @State private var currentScreen: AppScreenState = .start // 現在の画面状態を管理する変数

    var body: some View {
        ZStack {
            // 現在の画面に応じて表示を切り替え
            switch currentScreen {
            case .start:
                startScreenContent
            case .countdown:
                CountdownView(onComplete: {
                    currentScreen = .test
                })
                .environmentObject(testViewModel)
            case .test:
                TestView(onComplete: {
                    currentScreen = .result
                }, onCancel: {
                    currentScreen = .start
                })
                .environmentObject(testViewModel)
            case .result:
                ResultView(onReturnToStart: {
                    currentScreen = .start
                })
                .environmentObject(testViewModel)
            }
        }
        .navigationTitle("")
        .navigationBarHidden(true)
        .alert("検査を開始しますか？", isPresented: $showingConfirmation) {
            Button("はい") {
                testViewModel.resetTest() // リセットしてから開始
                currentScreen = .countdown
            }
            Button("いいえ", role: .cancel) {
                showingConfirmation = false
            }
        }
        .sheet(isPresented: $showingHistory) {
            NavigationView {
                HistoryView()
                    .environmentObject(historyViewModel)
            }
        }
        .onAppear {
            Task {
                await historyViewModel.loadTestResults()
            }
        }
    }

    // MARK: - Start Screen Content
    private var startScreenContent: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                headerSection

                Spacer()

                mainContent

                Spacer()

                buttonSection

                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(.systemBackground))
        }
    }

    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: 16) {
            // App icon area
            ZStack {
                Circle()
                    .fill(LinearGradient(
                        gradient: Gradient(colors: [.blue.opacity(0.1), .blue.opacity(0.3)]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .frame(width: 100, height: 100)

                Image(systemName: "eye")
                    .font(.system(size: 40, weight: .medium))
                    .foregroundColor(.blue)
            }

            // App title
            VStack(spacing: 8) {
                Text("注意配分検査")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)

                Text("運転適正検査")
                    .font(.title2)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.top, 60)
    }

    // MARK: - Main Content
    private var mainContent: some View {
        VStack(spacing: 24) {
            // Instructions card
            instructionCard
        }
        .padding(.horizontal, 24)
    }

    private var instructionCard: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "info.circle.fill")
                    .foregroundColor(.blue)
                Text("検査について")
                    .font(.headline)
                    .fontWeight(.semibold)
                Spacer()
            }

            VStack(alignment: .leading, spacing: 8) {
                InstructionRow(
                    icon: "grid.circle",
                    text: "マス目に0〜48の数字がランダムに並んでいます"
                )
                InstructionRow(
                    icon: "hand.tap",
                    text: "0から順番に48まで数字をタップしてください"
                )
                InstructionRow(
                    icon: "checkmark.circle",
                    text: "数字を一つ押すたびに確認ボタンを押してください"
                )
                InstructionRow(
                    icon: "timer",
                    text: "最後の数字が押されるまでの時間を計測します"
                )
            }
        }
        .padding(20)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
    }

    // MARK: - Button Section
    private var buttonSection: some View {
        VStack(spacing: 16) {
            // Main action button
            Button(action: {
                showingConfirmation = true
            }) {
                Text("検査開始")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(.blue)
                    .cornerRadius(12)
            }

            // History button (centered)
            Button(action: {
                showingHistory = true
            }) {
                Text("履歴確認")
                    .font(.title2)
                    .foregroundColor(.blue)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(12)
            }
        }
        .padding(.horizontal, 24)
    }
}

// MARK: - Supporting Views
struct InstructionRow: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .frame(width: 20)

            Text(text)
                .font(.callout)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.leading)

            Spacer()
        }
    }
}

#Preview {
    StartView()
        .environmentObject(TestViewModel())
        .environmentObject(HistoryViewModel())
}
