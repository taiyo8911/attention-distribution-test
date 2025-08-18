//
//  TimerView.swift
//  attention-distribution-test
//
//  Created by Taiyo KOSHIBA on 2025/08/18.
//

import SwiftUI

// MARK: - Timer View Component
struct TimerView: View {

    // MARK: - Properties
    let elapsedTime: TimeInterval
    let gameState: GameState

    // Optional styling properties
    var style: TimerStyle = .normal
    var showMilliseconds: Bool = false // Changed default to false
    var animateChanges: Bool = true

    // MARK: - State
    @State private var isBlinking = false

    // MARK: - Body
    var body: some View {
        HStack(spacing: digitSpacing) {
            // Timer icon
            if style.showIcon {
                Image(systemName: iconName)
                    .font(.system(size: iconSize, weight: .medium))
                    .foregroundColor(iconColor)
                    .scaleEffect(isBlinking ? 1.2 : 1.0)
                    .animation(
                        Animation.easeInOut(duration: 0.5).repeatForever(autoreverses: true),
                        value: isBlinking
                    )
            }

            // Time display
            Text(formattedTime)
                .font(.system(
                    size: style.fontSize,
                    weight: style.fontWeight,
                    design: .monospaced
                ))
                .foregroundColor(textColor)
                .monospacedDigit()
        }
        .padding(style.padding)
        .background(backgroundColor)
        .cornerRadius(style.cornerRadius)
        .overlay(
            RoundedRectangle(cornerRadius: style.cornerRadius)
                .stroke(borderColor, lineWidth: borderWidth)
        )
        .scaleEffect(animateChanges && gameState == .inProgress ? 1.0 : 0.95)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: gameState)
        .onAppear {
            updateBlinkingState()
        }
        .onChange(of: gameState) { _ in
            updateBlinkingState()
        }
        .onChange(of: elapsedTime) { newTime in
            if animateChanges {
                updateDigitAnimation(newTime)
            }
        }
    }

    // MARK: - Private Methods
    private func updateBlinkingState() {
        switch gameState {
        case .paused:
            isBlinking = true
        case .inProgress:
            isBlinking = false
        default:
            isBlinking = false
        }
    }

    private func updateDigitAnimation(_ newTime: TimeInterval) {
        // Simplified - no individual digit animation for now
        // This can be implemented later if needed
    }

    // MARK: - Computed Properties
    private var formattedTime: String {
        if showMilliseconds {
            return elapsedTime.detailedFormattedTime
        } else {
            return elapsedTime.formattedTime
        }
    }

    private var iconName: String {
        switch gameState {
        case .inProgress:
            return "timer"
        case .paused:
            return "pause.circle"
        case .completed:
            return "checkmark.circle"
        default:
            return "clock"
        }
    }

    private var iconColor: Color {
        switch gameState {
        case .inProgress:
            return .blue
        case .paused:
            return .orange
        case .completed:
            return .green
        default:
            return .gray
        }
    }

    private var iconSize: CGFloat {
        style.fontSize * 0.8
    }

    private var textColor: Color {
        switch gameState {
        case .inProgress:
            return style.textColor
        case .paused:
            return .orange
        case .completed:
            return .green
        default:
            return .gray
        }
    }

    private var backgroundColor: Color {
        switch style {
        case .normal:
            return .clear
        case .prominent:
            return Color(.systemBackground)
        case .compact:
            return Color(.secondarySystemBackground)
        }
    }

    private var borderColor: Color {
        switch gameState {
        case .inProgress:
            return .blue.opacity(0.3)
        case .paused:
            return .orange.opacity(0.5)
        default:
            return .clear
        }
    }

    private var borderWidth: CGFloat {
        gameState == .inProgress || gameState == .paused ? 1.0 : 0
    }

    private var digitSpacing: CGFloat {
        style.spacing
    }

    private var separatorFont: Font {
        .system(size: style.fontSize * 0.8, weight: .medium, design: .monospaced)
    }
}

// MARK: - Timer Styles
extension TimerView {
    enum TimerStyle {
        case normal
        case prominent
        case compact

        var fontSize: CGFloat {
            switch self {
            case .normal: return 24
            case .prominent: return 32
            case .compact: return 18
            }
        }

        var fontWeight: Font.Weight {
            switch self {
            case .normal: return .semibold
            case .prominent: return .bold
            case .compact: return .medium
            }
        }

        var spacing: CGFloat {
            switch self {
            case .normal: return 8
            case .prominent: return 12
            case .compact: return 4
            }
        }

        var padding: EdgeInsets {
            switch self {
            case .normal: return EdgeInsets(top: 8, leading: 12, bottom: 8, trailing: 12)
            case .prominent: return EdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16)
            case .compact: return EdgeInsets(top: 4, leading: 8, bottom: 4, trailing: 8)
            }
        }

        var cornerRadius: CGFloat {
            switch self {
            case .normal: return 8
            case .prominent: return 12
            case .compact: return 6
            }
        }

        var textColor: Color {
            return .primary
        }

        var digitBackgroundColor: Color {
            switch self {
            case .normal: return .clear
            case .prominent: return Color(.tertiarySystemBackground)
            case .compact: return .clear
            }
        }

        var showIcon: Bool {
            switch self {
            case .normal: return true
            case .prominent: return true
            case .compact: return false
            }
        }
    }
}

// MARK: - Digit Group Component
struct DigitGroup: View {
    let digits: [Character]
    let style: DigitStyle

    var body: some View {
        HStack(spacing: 2) {
            ForEach(Array(digits.enumerated()), id: \.offset) { index, digit in
                DigitView(
                    digit: String(digit),
                    style: style
                )
            }
        }
    }
}

// MARK: - Individual Digit View
struct DigitView: View {
    let digit: String
    let style: DigitStyle

    @State private var isAnimating = false

    var body: some View {
        Text(digit)
            .font(.system(
                size: style.fontSize,
                weight: style.fontWeight,
                design: .monospaced
            ))
            .foregroundColor(style.textColor)
            .frame(minWidth: style.minWidth)
            .padding(.horizontal, 2)
            .background(style.backgroundColor)
            .cornerRadius(4)
            .scaleEffect(isAnimating ? 1.1 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: isAnimating)
            .onChange(of: digit) { _ in
                withAnimation(.easeInOut(duration: 0.1)) {
                    isAnimating = true
                }

                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    withAnimation(.easeInOut(duration: 0.1)) {
                        isAnimating = false
                    }
                }
            }
    }
}

// MARK: - Digit Style
struct DigitStyle {
    let fontSize: CGFloat
    let fontWeight: Font.Weight
    let textColor: Color
    let backgroundColor: Color

    var minWidth: CGFloat {
        fontSize * 0.7
    }

    func smaller() -> DigitStyle {
        DigitStyle(
            fontSize: fontSize * 0.8,
            fontWeight: fontWeight,
            textColor: textColor.opacity(0.8),
            backgroundColor: backgroundColor
        )
    }
}

// MARK: - Accessibility
extension TimerView {
    private var accessibilityLabel: String {
        let timeString = elapsedTime.formattedTime.replacingOccurrences(of: ":", with: "分").appending("秒")

        switch gameState {
        case .inProgress:
            return "経過時間: \(timeString)"
        case .paused:
            return "一時停止中: \(timeString)"
        case .completed:
            return "完了時間: \(timeString)"
        default:
            return "時間: \(timeString)"
        }
    }
}

// MARK: - Preview Support
struct TimerView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 30) {
            TimerView(
                elapsedTime: 125.67,
                gameState: .inProgress,
                style: .normal
            )

            TimerView(
                elapsedTime: 125.67,
                gameState: .paused,
                style: .prominent
            )

            TimerView(
                elapsedTime: 125.67,
                gameState: .completed,
                style: .compact,
                showMilliseconds: false
            )
        }
        .padding()
        .previewLayout(.sizeThatFits)
        .previewDisplayName("Timer Variations")
    }
}
