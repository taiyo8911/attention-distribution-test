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
    @State private var currentScreen: AppScreenState = .start

    var body: some View {
        NavigationStack {
            ZStack {
                switch currentScreen {
                case .start:
                    StartView(currentScreen: $currentScreen)
                case .countdown:
                    CountdownView {
                        currentScreen = .test
                    }
                case .test:
                    TestView(onComplete: {
                        currentScreen = .result
                    }, onCancel: {
                        currentScreen = .start
                    })
                case .result:
                    ResultView {
                        currentScreen = .start
                    }
                }
            }
            .environmentObject(testViewModel)
            .environmentObject(historyViewModel)
        }
    }
}

#Preview {
    ContentView()
}
