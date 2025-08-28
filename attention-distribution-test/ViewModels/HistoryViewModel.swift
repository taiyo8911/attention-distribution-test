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

    // MARK: - Initializer
    // HistoryViewModelを作る時の初期設定
    init(dataService: DataServiceProtocol = DataService()) {
        self.dataService = dataService

        // アプリが起動したら自動で過去の結果を読み込む
        Task {
            await loadTestResults()
        }
    }

    // MARK: - Public Methods
    // 過去の検査結果をファイルから読み込んで表示用リストに保存する
    func loadTestResults() async {
        do {
            // DataServiceを使って保存された結果を取得
            let results = try await dataService.loadTestResults()
            // 新しい順番に並び替える（一番最近やったものが上に来る）
            testResults = results.sorted { $0.date > $1.date }
            print("Loaded \(results.count) test results")  // デバッグ用：何件読み込めたか表示
        } catch {
            // 読み込みに失敗した場合の処理
            print("Failed to load test results: \(error)")  // エラー内容を表示
            testResults = []  // 空のリストにする
        }
    }
}

// MARK: - Mock History View Model for Preview
// プレビュー用のテスト版HistoryViewModel（実際のアプリでは使わない）
#if DEBUG
class MockHistoryViewModel: HistoryViewModel {
    override init(dataService: DataServiceProtocol = MockDataService()) {
        super.init(dataService: dataService)  // テスト用のデータサービスを使う
    }
}
#endif
