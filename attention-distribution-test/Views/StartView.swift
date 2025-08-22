//
//  StartView.swift
//  attention-distribution-test
//
//  Created by Taiyo KOSHIBA on 2025/08/18.
//

import SwiftUI

struct StartView: View {
    @EnvironmentObject var testViewModel: TestViewModel
    @EnvironmentObject var historyViewModel: HistoryViewModel

    @State private var showingConfirmation = false
    @State private var showingHistory = false
    @State private var showingCountdown = false

    var body: some View {
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
        .navigationTitle("")
        .navigationBarHidden(true)
        .alert("検査を開始しますか？", isPresented: $showingConfirmation) {
            Button("YES") {
                testViewModel.startCountdown()
                showingCountdown = true

            }
            Button("NO", role: .cancel) {
                showingConfirmation = false
            }
        }
        .sheet(isPresented: $showingHistory) {
            HistoryView()
                .environmentObject(historyViewModel)
        }
        .fullScreenCover(isPresented: $showingCountdown) {
            CountdownView()
                .environmentObject(testViewModel)
        }
        .onAppear {
            Task {
                await historyViewModel.loadTestResults()
            }
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

                Image(systemName: "brain.head.profile")
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
                    text: "7×7のマスに0〜48の数字がランダムに並んでいます"
                )
                InstructionRow(
                    icon: "hand.tap",
                    text: "0から順番に48まで数字をタップしてください"
                )
                InstructionRow(
                    icon: "checkmark.circle",
                    text: "数字を一つ押すたびに確認ボタンを押してから次へ進んでください"
                )
                InstructionRow(
                    icon: "timer",
                    text: "終了するまでの時間を計測します"
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
