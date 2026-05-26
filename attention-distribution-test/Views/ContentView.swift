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
        NavigationStack {
            StartView()
                .environmentObject(testViewModel)
                .environmentObject(historyViewModel)
        }
    }
}

#Preview {
    ContentView()
}
