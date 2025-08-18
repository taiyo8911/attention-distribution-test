//
//  GameState.swift
//  attention-distribution-test
//
//  Created by Taiyo KOSHIBA on 2025/08/18.
//


import Foundation

// MARK: - Game State Enumeration
enum GameState: String, CaseIterable {
    case notStarted = "not_started"
    case confirmationDialog = "confirmation_dialog"
    case countdown = "countdown"
    case inProgress = "in_progress"
    case paused = "paused"
    case completed = "completed"
    case cancelled = "cancelled"
    
    // MARK: - State Properties
    var isTestActive: Bool {
        switch self {
        case .inProgress, .paused:
            return true
        default:
            return false
        }
    }
    
    var canStartTest: Bool {
        switch self {
        case .notStarted, .completed, .cancelled:
            return true
        default:
            return false
        }
    }
    
    var shouldShowTimer: Bool {
        switch self {
        case .inProgress, .paused, .completed:
            return true
        default:
            return false
        }
    }
    
    var shouldAcceptInput: Bool {
        switch self {
        case .inProgress:
            return true
        default:
            return false
        }
    }
    
    // MARK: - State Transitions
    func canTransition(to newState: GameState) -> Bool {
        switch (self, newState) {
        case (.notStarted, .confirmationDialog),
             (.confirmationDialog, .countdown),
             (.confirmationDialog, .notStarted),
             (.countdown, .inProgress),
             (.inProgress, .paused),
             (.inProgress, .completed),
             (.inProgress, .cancelled),
             (.paused, .inProgress),
             (.paused, .cancelled),
             (.completed, .notStarted),
             (.cancelled, .notStarted):
            return true
        default:
            return false
        }
    }
    
    // MARK: - Display Properties
    var displayName: String {
        switch self {
        case .notStarted:
            return "未開始"
        case .confirmationDialog:
            return "確認中"
        case .countdown:
            return "カウントダウン"
        case .inProgress:
            return "検査中"
        case .paused:
            return "一時停止"
        case .completed:
            return "完了"
        case .cancelled:
            return "中断"
        }
    }
    
    var description: String {
        switch self {
        case .notStarted:
            return "検査を開始できます"
        case .confirmationDialog:
            return "検査開始の確認中"
        case .countdown:
            return "検査開始のカウントダウン中"
        case .inProgress:
            return "検査を実行中"
        case .paused:
            return "検査を一時停止中"
        case .completed:
            return "検査が正常に完了しました"
        case .cancelled:
            return "検査が中断されました"
        }
    }
}
