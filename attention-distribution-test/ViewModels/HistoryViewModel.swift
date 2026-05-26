//
//  HistoryViewModel.swift
//  attention-distribution-test
//
//  Created by Taiyo KOSHIBA on 2025/08/18.
//

import Foundation
import SwiftUI

// MARK: - History View Model
// 過去の検査結果を管理するクラス
@MainActor
class HistoryViewModel: ObservableObject {

    // MARK: - Published Properties
    @Published private(set) var testResults: [TestResult] = []  // 過去の検査結果のリスト（画面に表示される）

    // MARK: - Dependencies
    let dataService: DataServiceProtocol  // データを保存・読み込みするサービス

    // MARK: - Statistics
    // 実施回数
    var testCount: Int {
        testResults.count
    }

    // 自己ベスト（最短完了時間）
    var bestTime: TimeInterval? {
        testResults.map(\.completionTime).min()
    }

    // 平均タイム
    var averageTime: TimeInterval? {
        guard !testResults.isEmpty else { return nil }
        let total = testResults.reduce(0) { $0 + $1.completionTime }
        return total / Double(testResults.count)
    }

    // MARK: - Initializer
    // HistoryViewModelを作る時の初期設定
    init(dataService: DataServiceProtocol = DataService()) {
        self.dataService = dataService
    }

    // MARK: - Public Methods
    // 過去の検査結果をファイルから読み込んで表示用リストに保存する
    func loadTestResults() async {
        do {
            // DataServiceを使って保存された結果を取得
            let results = try await dataService.loadTestResults()
            // 新しい順番に並び替える（一番最近やったものが上に来る）
            testResults = results.sorted { $0.date > $1.date }
        } catch {
            // 読み込みに失敗した場合は空にする
            testResults = []
        }
    }

    // 履歴を全件削除する
    func deleteAllTestResults() async {
        try? await dataService.deleteAllTestResults()
        testResults = []
    }
}

