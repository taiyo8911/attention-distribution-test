//
//  TimerView.swift
//  attention-distribution-test
//
//  Created by Taiyo KOSHIBA on 2025/08/18.
//

import SwiftUI

struct TimerView: View {
    let elapsedTime: TimeInterval

    var body: some View {
        Text(formattedTime)
            .font(.title)
            .fontWeight(.semibold)
            .monospacedDigit()
    }

    private var formattedTime: String {
        let minutes = Int(elapsedTime) / 60
        let seconds = Int(elapsedTime) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

#Preview {
    VStack(spacing: 20) {
        TimerView(elapsedTime: 0)
        TimerView(elapsedTime: 125.67)
        TimerView(elapsedTime: 3661.23)
    }
    .padding()
}
