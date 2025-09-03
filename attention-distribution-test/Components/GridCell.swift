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
                            .stroke(Color.black, lineWidth: strokeWidth)
                    )

                // 数字表示
                Text("\(number)")
                    .font(.system(size: fontSize, weight: fontWeight))
                    .foregroundColor(.black)
                    .minimumScaleFactor(0.7) // 小画面で文字が収まらない場合のスケールファクター
                    .lineLimit(1)
            }
        }
        .frame(width: cellSize, height: cellSize)
        .buttonStyle(PlainButtonStyle())
    }

    // 動的フォントサイズ計算
    private var fontSize: CGFloat {
        let baseRatio: CGFloat = 0.55 // 基本比率を少し大きく
        let calculatedSize = cellSize * baseRatio

        // セルサイズに応じた最小・最大フォントサイズ
        if cellSize < 40 {
            return max(12, calculatedSize) // 極小画面対応
        } else if cellSize < 50 {
            return max(16, calculatedSize) // 小画面対応
        } else {
            return max(20, calculatedSize) // 通常画面
        }
    }

    // フォントウェイト調整
    private var fontWeight: Font.Weight {
        return cellSize < 45 ? .semibold : .medium // 小さいセルでは太めに
    }

    // ストローク幅調整
    private var strokeWidth: CGFloat {
        return cellSize < 40 ? 0.8 : 1.0 // 小さいセルでは線を細く
    }
}

#Preview {
    VStack(spacing: 10) {
        // 通常サイズ
        HStack(spacing: 2) {
            GridCell(number: 0, isSelected: false, cellSize: 60) { }
            GridCell(number: 15, isSelected: true, cellSize: 60) { }
            GridCell(number: 23, isSelected: false, cellSize: 60) { }
        }

        // 小画面サイズ
        HStack(spacing: 2) {
            GridCell(number: 0, isSelected: false, cellSize: 40) { }
            GridCell(number: 15, isSelected: true, cellSize: 40) { }
            GridCell(number: 23, isSelected: false, cellSize: 40) { }
        }

        // 極小画面サイズ
        HStack(spacing: 2) {
            GridCell(number: 0, isSelected: false, cellSize: 35) { }
            GridCell(number: 15, isSelected: true, cellSize: 35) { }
            GridCell(number: 23, isSelected: false, cellSize: 35) { }
        }
    }
    .padding()
}
