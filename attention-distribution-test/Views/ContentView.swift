//
//  ContentView.swift
//  attention-distribution-test
//
//  Created by Taiyo KOSHIBA on 2025/08/18.
//

import SwiftUI

// MARK: - Main Content View
struct ContentView: View {
    @StateObject private var testViewModel = TestViewModel()
    @StateObject private var historyViewModel = HistoryViewModel()

    var body: some View {
        NavigationView {
            StartView()
                .environmentObject(testViewModel)
                .environmentObject(historyViewModel)
        }
        .navigationViewStyle(StackNavigationViewStyle()) // iPhone/iPad対応
    }
}

// MARK: - Preview
#Preview {
    ContentView()
}

// MARK: - Legacy Support (backward compatibility)
// These extensions provide compatibility with the existing codebase
// They can be removed once all views are updated to use the new architecture

extension TestViewModel {
    // Legacy properties for backward compatibility
    var testResults: [TestResult] {
        // This would typically be managed by HistoryViewModel
        return []
    }

    // Legacy methods for backward compatibility
    func saveTestHistory() {
        // This functionality is now handled by DataService
        Task {
            // Implementation would call DataService
        }
    }

    func loadTestHistory() {
        // This functionality is now handled by HistoryViewModel
    }
}
