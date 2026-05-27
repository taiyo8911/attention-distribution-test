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
    @Binding var currentScreen: AppScreenState

    @State private var showingConfirmation = false // 検査開始確認アラート用の変数
    @State private var showingHistory = false // 履歴表示用の変数

    // MARK: - Layout Constants
    // 画面の上下マージンと、セクション間の最小スペーシングを定数化
    private let topMargin: CGFloat = 40
    private let bottomMargin: CGFloat = 32
    private let horizontalMargin: CGFloat = 24

    var body: some View {
        VStack(spacing: 0) {
            headerSection

            Spacer(minLength: 24)

            mainContent

            Spacer(minLength: 24)

            buttonSection
        }
        .padding(.top, topMargin)
        .padding(.bottom, bottomMargin)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
        .navigationTitle("")
        .toolbar(.hidden, for: .navigationBar)
        .alert("Start the test?", isPresented: $showingConfirmation) {
            Button("Start") {
                currentScreen = .countdown
            }
            Button("Cancel", role: .cancel) {
                showingConfirmation = false
            }
        }
        .sheet(isPresented: $showingHistory) {
            NavigationStack {
                HistoryView()
                    .environmentObject(historyViewModel)
            }
        }
        .dynamicTypeSize(...DynamicTypeSize.xxxLarge)
    }

    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: 24) {
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
            Text("Attention Distribution Test")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.primary)
        }
    }

    // MARK: - Main Content
    private var mainContent: some View {
        VStack(spacing: 24) {
            // Instructions card
            instructionCard
        }
        .padding(.horizontal, horizontalMargin)
    }

    private var instructionCard: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "info.circle.fill")
                    .foregroundColor(.blue)
                Text("How It Works")
                    .font(.headline)
                    .fontWeight(.semibold)
                Spacer()
            }

            VStack(alignment: .leading, spacing: 8) {
                InstructionRow(
                    icon: "checkmark.circle",
                    text: "Tap numbers from 0 to 48 in order."
                )
                InstructionRow(
                    icon: "checkmark.circle",
                    text: "Start from the 0 at the center."
                )
                InstructionRow(
                    icon: "checkmark.circle",
                    text: "After tapping a number, press the Confirm button to proceed."
                )
            }
        }
        .padding(20)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(16)
        .shadow(color: Color.primary.opacity(0.1), radius: 8, x: 0, y: 4)
    }

    // MARK: - Button Section
    private var buttonSection: some View {
        VStack(spacing: 16) {
            // Main action button
            Button(action: {
                showingConfirmation = true
            }) {
                Text("Start Test")
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
                Text("History")
                    .font(.title2)
                    .foregroundColor(.blue)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(12)
            }
        }
        .padding(.horizontal, horizontalMargin)
    }
}

// MARK: - Supporting Views
struct InstructionRow: View {
    let icon: String
    let text: LocalizedStringKey

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
    NavigationStack {
        StartView(currentScreen: .constant(.start))
            .environmentObject(TestViewModel())
            .environmentObject(HistoryViewModel())
    }
}
