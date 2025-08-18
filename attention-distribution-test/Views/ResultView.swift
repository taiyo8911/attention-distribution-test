//
//  ResultView.swift
//  attention-distribution-test
//
//  Created by Taiyo KOSHIBA on 2025/08/18.
//

import SwiftUI

struct ResultView: View {
    @EnvironmentObject var testManager: TestManager
    @State private var showingHistory = false
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            // 完了メッセージ
            VStack(spacing: 20) {
                Text("検査終了")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                // 完了時間表示
                VStack(spacing: 8) {
                    Text("検査時間")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    Text(testManager.elapsedTime.formattedTime)
                        .font(.system(size: 36, weight: .bold, design: .monospaced))
                        .foregroundColor(.blue)
                }
                .padding()
                .background(Color.blue.opacity(0.1))
                .cornerRadius(12)
            }
            
            Spacer()
            
            // ボタン群
            VStack(spacing: 16) {
                Button(action: {
                    dismiss()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        // 新しいテストを開始するためのロジック
                        // StartViewに戻って新しいテストを開始
                    }
                }) {
                    Text("もう一度")
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
                
                Button(action: {
                    dismiss()
                }) {
                    Text("メインへ戻る")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(12)
                }
            }
            .padding(.horizontal, 40)
            
            Spacer()
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $showingHistory) {
            HistoryView()
                .environmentObject(testManager)
        }
    }
}

#Preview {
    ResultView()
        .environmentObject(TestManager())
}
