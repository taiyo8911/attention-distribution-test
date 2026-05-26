//
//  GridBoard.swift
//  attention-distribution-test
//
//  Created by Taiyo KOSHIBA on 2025/08/18.
//

import SwiftUI

// 検査のマス目を一括で描画するコンポーネント
struct GridBoard: View {
    @EnvironmentObject var testViewModel: TestViewModel
    let cellSize: CGFloat

    var body: some View {
        let dimension = testViewModel.gridSize
        let totalSize = cellSize * CGFloat(dimension) + CGFloat(dimension - 1)

        VStack(spacing: 1) {
            ForEach(0..<dimension, id: \.self) { row in
                HStack(spacing: 1) {
                    ForEach(0..<dimension, id: \.self) { col in
                        GridCell(
                            number: testViewModel.getNumber(at: row, col: col),
                            isSelected: testViewModel.isSelected(row: row, col: col),
                            cellSize: cellSize
                        ) {
                            testViewModel.tapNumber(at: row, col: col)
                        }
                    }
                }
            }
        }
        .frame(width: totalSize, height: totalSize)
    }
}
