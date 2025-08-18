//
//  GridCell.swift
//  attention-distribution-test
//
//  Created by Taiyo KOSHIBA on 2025/08/18.
//

import SwiftUI

// MARK: - Grid Cell Component
struct GridCell: View {
    
    // MARK: - Properties
    let number: Int
    let isSelected: Bool
    let cellSize: CGFloat
    let action: () -> Void
    
    // Optional styling properties
    var isCurrentTarget: Bool = false
    var isCompleted: Bool = false
    var animationDelay: Double = 0
    
    // MARK: - State
    @State private var isPressed = false
    @State private var showCompletionAnimation = false
    
    // MARK: - Body
    var body: some View {
        Button(action: {
            performAction()
        }) {
            ZStack {
                // Background
                RoundedRectangle(cornerRadius: cellCornerRadius)
                    .fill(backgroundColor)
                    .overlay(
                        RoundedRectangle(cornerRadius: cellCornerRadius)
                            .stroke(borderColor, lineWidth: borderWidth)
                    )
                
                // Number text
                if number >= 0 {
                    Text("\(number)")
                        .font(.system(
                            size: fontSize,
                            weight: fontWeight,
                            design: .rounded
                        ))
                        .foregroundColor(textColor)
                        .scaleEffect(textScale)
                        .animation(
                            .spring(response: 0.3, dampingFraction: 0.6),
                            value: isSelected
                        )
                }
                
                // Completion overlay
                if showCompletionAnimation {
                    Circle()
                        .fill(Color.green.opacity(0.3))
                        .scaleEffect(2.0)
                        .opacity(0)
                        .animation(
                            .easeOut(duration: 0.5),
                            value: showCompletionAnimation
                        )
                }
            }
        }
        .frame(width: cellSize, height: cellSize)
        .scaleEffect(isPressed ? 0.95 : 1.0)
        .animation(.easeInOut(duration: 0.1), value: isPressed)
        .buttonStyle(PlainButtonStyle())
        .onAppear {
            if animationDelay > 0 {
                DispatchQueue.main.asyncAfter(deadline: .now() + animationDelay) {
                    withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                        // Cell appearance animation
                    }
                }
            }
        }
        .onChange(of: isCompleted) { completed in
            if completed {
                triggerCompletionAnimation()
            }
        }
    }
    
    // MARK: - Private Methods
    private func performAction() {
        // Visual feedback
        withAnimation(.easeInOut(duration: 0.1)) {
            isPressed = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = false
            }
        }
        
        // Execute action
        action()
    }
    
    private func triggerCompletionAnimation() {
        withAnimation(.easeOut(duration: 0.5)) {
            showCompletionAnimation = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            showCompletionAnimation = false
        }
    }
    
    // MARK: - Computed Properties
    private var cellCornerRadius: CGFloat {
        cellSize * 0.1
    }
    
    private var fontSize: CGFloat {
        cellSize * 0.6 // 60% of cell size as per specification
    }
    
    private var fontWeight: Font.Weight {
        if isCurrentTarget {
            return .bold
        } else if isSelected {
            return .semibold
        } else {
            return .medium
        }
    }
    
    private var textScale: CGFloat {
        if isSelected {
            return 1.1
        } else if isCurrentTarget {
            return 1.05
        } else {
            return 1.0
        }
    }
    
    private var backgroundColor: Color {
        if isCompleted {
            return Color.green.opacity(0.2)
        } else if isSelected {
            return Color.yellow.opacity(0.7)
        } else if isCurrentTarget {
            return Color.blue.opacity(0.1)
        } else {
            return Color.white
        }
    }
    
    private var textColor: Color {
        if isCompleted {
            return .green
        } else if isSelected {
            return .black
        } else if isCurrentTarget {
            return .blue
        } else {
            return .black
        }
    }
    
    private var borderColor: Color {
        if isSelected {
            return .yellow
        } else if isCurrentTarget {
            return .blue
        } else {
            return .black
        }
    }
    
    private var borderWidth: CGFloat {
        if isSelected || isCurrentTarget {
            return 2.0
        } else {
            return 1.0
        }
    }
}

// MARK: - Grid Cell Styles
extension GridCell {
    enum CellStyle {
        case normal
        case highlighted
        case completed
        case error
        
        var backgroundColor: Color {
            switch self {
            case .normal: return .white
            case .highlighted: return .yellow.opacity(0.7)
            case .completed: return .green.opacity(0.2)
            case .error: return .red.opacity(0.2)
            }
        }
        
        var borderColor: Color {
            switch self {
            case .normal: return .black
            case .highlighted: return .yellow
            case .completed: return .green
            case .error: return .red
            }
        }
        
        var textColor: Color {
            switch self {
            case .normal: return .black
            case .highlighted: return .black
            case .completed: return .green
            case .error: return .red
            }
        }
    }
}

// MARK: - Accessibility
extension GridCell {
    private var accessibilityLabel: String {
        var label = "数字\(number)"
        
        if isSelected {
            label += "、選択中"
        }
        
        if isCurrentTarget {
            label += "、次のターゲット"
        }
        
        if isCompleted {
            label += "、完了"
        }
        
        return label
    }
    
    private var accessibilityHint: String {
        if isCurrentTarget {
            return "この数字をタップしてください"
        } else if isCompleted {
            return "この数字は既に完了しています"
        } else {
            return "数字\(number)をタップ"
        }
    }
}

// MARK: - Preview Support
struct GridCell_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            HStack(spacing: 20) {
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
                    cellSize: 60,
                    isCurrentTarget: true
                ) {
                    print("Tapped 23")
                }
                
                GridCell(
                    number: 5,
                    isSelected: false,
                    cellSize: 60,
                    isCompleted: true
                ) {
                    print("Tapped 5")
                }
            }
            
            // Different sizes
            HStack(spacing: 20) {
                GridCell(
                    number: 42,
                    isSelected: false,
                    cellSize: 40
                ) {
                    print("Tapped small")
                }
                
                GridCell(
                    number: 7,
                    isSelected: false,
                    cellSize: 80
                ) {
                    print("Tapped large")
                }
            }
        }
        .padding()
        .previewLayout(.sizeThatFits)
        .previewDisplayName("Grid Cell Variations")
    }
}
