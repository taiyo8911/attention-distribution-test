//
//  ContentView.swift
//  attention-distribution-test
//
//  Created by Taiyo KOSHIBA on 2025/08/18.
//

import SwiftUI

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

#Preview {
    ContentView()
}
