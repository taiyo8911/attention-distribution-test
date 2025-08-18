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
                // 背景
                Rectangle()
                    .fill(backgroundColor)
                    .overlay(
                        Rectangle()
                            .stroke(Color.black, lineWidth: 1)
                    )

                // 数字表示
                if number >= 0 {
                    Text("\(number)")
                        .font(.system(size: fontSize, weight: .medium))
                        .foregroundColor(.black)
                } else {
                    // -1の場合は何も表示しない（初期化前の状態）
                    Text("")
                        .font(.system(size: fontSize, weight: .medium))
                }
            }
        }
        .frame(width: cellSize, height: cellSize)
        .buttonStyle(PlainButtonStyle())
    }

    // MARK: - Computed Properties
    private var fontSize: CGFloat {
        cellSize * 0.6
    }

    private var backgroundColor: Color {
        isSelected ? Color.yellow.opacity(0.7) : Color.white
    }
}

#Preview {
    HStack(spacing: 2) {
        GridCell(
            number: 0,
            isSelected: false,
            cellSize: 60
        ) {
            print("Tapped 0")
        }

        GridCell(
            number: 15,
            isSelected: true,
            cellSize: 60
        ) {
            print("Tapped 15")
        }

        GridCell(
            number: 23,
            isSelected: false,
            cellSize: 60
        ) {
            print("Tapped 23")
        }
    }
    .padding()
}
