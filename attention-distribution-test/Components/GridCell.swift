//
//  GridCell.swift
//  attention-distribution-test
//
//  Created by Taiyo KOSHIBA on 2025/08/18.
//

import SwiftUI

struct GridCell: View {
    let number: Int
    let isSelected: Bool
    let cellSize: CGFloat
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                // 白背景
                Rectangle()
                    .fill(isSelected ? Color.yellow.opacity(0.7) : Color.white)
                    .overlay(
                        Rectangle()
                            .stroke(Color.black, lineWidth: 1)
                    )

                // 数字表示
                Text("\(number)")
                    .font(.system(size: fontSize, weight: .medium))
                    .foregroundColor(.black)
            }
        }
        .frame(width: cellSize, height: cellSize)
        .buttonStyle(PlainButtonStyle())
    }

    private var fontSize: CGFloat {
        cellSize * 0.6
    }
}

#Preview {
    HStack(spacing: 2) {
        GridCell(number: 0, isSelected: false, cellSize: 60) { }
        GridCell(number: 15, isSelected: true, cellSize: 60) { }
        GridCell(number: 23, isSelected: false, cellSize: 60) { }
    }
    .padding()
}
