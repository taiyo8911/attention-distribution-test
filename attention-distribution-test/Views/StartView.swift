//
//  StartView.swift
//  attention-distribution-test
//
//  Created by Taiyo KOSHIBA on 2025/08/18.
//


import SwiftUI

struct StartView: View {
    @EnvironmentObject var testManager: TestManager
    @State private var showingConfirmation = false
    @State private var showingHistory = false
    @State private var showingCountdown = false

    var body: some View {
        VStack(spacing: 40) {
            Spacer()

            // アプリタイトル
            VStack(spacing: 16) {
                Text("注意配分検査")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Text("運転適正検査")
                    .font(.title2)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
            }

            Spacer()

            // メインボタン
            VStack(spacing: 20) {
                Button(action: {
                    showingConfirmation = true
                }) {
                    Text("検査開始")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.blue)
                        .cornerRadius(12)
                }

                Button(action: {
                    showingHistory = true
                }) {
                    Text("履歴確認")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.blue)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(12)
                }
            }
            .padding(.horizontal, 40)

            Spacer()
        }
        .navigationTitle("")
        .navigationBarHidden(true)
        .alert("検査を開始しますか？", isPresented: $showingConfirmation) {
            Button("YES") {
                showingCountdown = true
            }
            Button("NO", role: .cancel) {
                showingConfirmation = false
            }
        }
        .sheet(isPresented: $showingHistory) {
            HistoryView()
                .environmentObject(testManager)
        }
        .fullScreenCover(isPresented: $showingCountdown) {
            CountdownView()
                .environmentObject(testManager)
        }
    }
}


#Preview {
    StartView()
}
