//
//  ConfirmButton.swift
//  attention-distribution-test
//
//  Created by Taiyo KOSHIBA on 2025/08/18.
//

import SwiftUI

// 確認ボタン（縦・横レイアウト共通）
struct ConfirmButton: View {
    @EnvironmentObject var testViewModel: TestViewModel
    let isCompact: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text("Confirm")
                .font(isCompact ? .title3 : .title2)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .frame(maxWidth: isCompact ? 280 : 400)
                .frame(height: isCompact ? 44 : 60)
        }
        .background(testViewModel.canConfirm ? .blue : .gray)
        .cornerRadius(isCompact ? 8 : 12)
        .disabled(!testViewModel.canConfirm)
    }
}
