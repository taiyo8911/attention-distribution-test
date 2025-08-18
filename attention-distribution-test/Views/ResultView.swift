//
//  ResultView.swift
//  attention-distribution-test
//
//  Created by Taiyo KOSHIBA on 2025/08/18.
//

import SwiftUI

struct ResultView: View {
    @EnvironmentObject var testViewModel: TestViewModel
    @StateObject private var historyViewModel = HistoryViewModel()

    @State private var showingShareSheet = false
    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack(spacing: 50) {
            Spacer()

            // Title
            Text("検査終了")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.primary)

            // Completion time
            VStack(spacing: 8) {
                Text("記録")
                    .font(.headline)
                    .foregroundColor(.secondary)

                Text(formattedCompletionTime)
                    .font(.system(size: 48, weight: .bold, design: .monospaced))
                    .foregroundColor(.blue)
                    .monospacedDigit()
            }

            Spacer()

            // Action buttons
            VStack(spacing: 16) {
                Button(action: {
                    startNewTest()
                }) {
                    Text("もう一度")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(.blue)
                        .cornerRadius(12)
                }

                Button(action: {
                    showingShareSheet = true
                }) {
                    Text("結果を共有")
                        .font(.title3)
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
                    Text("終了")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.red)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.red.opacity(0.1))
                        .cornerRadius(12)
                }
            }
            .padding(.horizontal, 20)

            Spacer()
        }
        .navigationBarHidden(true)
        .background(Color(.systemBackground))
        .sheet(isPresented: $showingShareSheet) {
            ShareSheet(activityItems: [shareText])
        }
        .onAppear {
            saveTestResult()
        }
    }

    // MARK: - Computed Properties
    private var formattedCompletionTime: String {
        let minutes = Int(testViewModel.elapsedTime) / 60
        let seconds = Int(testViewModel.elapsedTime) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    private var shareText: String {
        return """
        注意配分検査の結果
        
        完了時間: \(formattedCompletionTime)
        日時: \(Date().formatted(date: .abbreviated, time: .shortened))
        
        #注意配分検査 #運転適性検査
        """
    }

    // MARK: - Methods
    private func startNewTest() {
        testViewModel.resetTest()
        dismiss()
    }

    private func saveTestResult() {
        Task {
            await saveResult()
        }
    }

    private func saveResult() async {
        guard let startTime = testViewModel.testModel.startTime,
              let endTime = testViewModel.testModel.endTime else { return }

        let result = TestResult(
            startTime: startTime,
            endTime: endTime,
            completionTime: testViewModel.elapsedTime
        )

        do {
            try await historyViewModel.dataService.saveTestResult(result)
            print("Test result saved successfully")
        } catch {
            print("Failed to save test result: \(error)")
        }
    }
}

// MARK: - Share Sheet
struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#Preview {
    let testViewModel = TestViewModel(
        timerService: MockTimerService(),
        dataService: MockDataService()
    )

    return ResultView()
        .environmentObject(testViewModel)
}
