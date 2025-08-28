//
//  GameState.swift
//  attention-distribution-test
//
//  Created by Taiyo KOSHIBA on 2025/08/18.
//

import Foundation

// MARK: - Game State Enumeration
// ゲームの状態を管理する列挙型
enum GameState: String, CaseIterable {
    case notStarted = "not_started"
    case inProgress = "in_progress"
    case completed = "completed"
    case cancelled = "cancelled"

    // MARK: - State Properties
    // 今ゲームをやってるかどうか
    var isTestActive: Bool {
        switch self {
        case .inProgress: // ゲーム中
            return true
        default:
            return false
        }
    }

    // ゲームを開始できるかどうか
    var canStartTest: Bool {
        switch self {
        case .notStarted, .completed, .cancelled:
            return true
        default:
            return false
        }
    }

    // タイマーを表示するかどうか
    var shouldShowTimer: Bool {
        switch self {
        case .inProgress, .completed:
            return true
        default:
            return false
        }
    }

    // 数字を入力できるかどうか
    var shouldAcceptInput: Bool {
        switch self {
        case .inProgress:
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
        case .inProgress:
            return "検査中"
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
        case .inProgress:
            return "検査を実行中"
        case .completed:
            return "検査が正常に完了しました"
        case .cancelled:
            return "検査が中断されました"
        }
    }
}
