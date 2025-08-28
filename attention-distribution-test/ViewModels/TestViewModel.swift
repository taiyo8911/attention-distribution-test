//
//  TestViewModel.swift
//  attention-distribution-test
//
//  Created by Taiyo KOSHIBA on 2025/08/18.
//

import Foundation
import Combine
import SwiftUI

// 検査の進行を管理するクラス（ゲームの司会者のような役割）
@MainActor
class TestViewModel: ObservableObject {

    // MARK: - Published Properties
    @Published private(set) var testModel = TestModel()        // 検査のデータ（マス目の数字や現在の状態）
    @Published private(set) var elapsedTime: TimeInterval = 0  // 経過時間（何秒たったか）

    // MARK: - Test Timing
    private var testStartTime: Date?  // 検査を始めた時刻を記録

    // MARK: - Dependencies
    private let timerService: TimerServiceProtocol    // 時間を測るサービス
    private let dataService: DataServiceProtocol      // データを保存するサービス
    private var cancellables = Set<AnyCancellable>()  // タイマーの監視を管理

    // MARK: - Computed Properties
    // 画面で使いやすいように、testModelの情報を取り出す
    var gameState: GameState { testModel.gameState }      // ゲームの状態
    var currentNumber: Int { testModel.currentNumber }    // 今押すべき数字
    var showError: Bool { testModel.showError }           // エラーを表示するかどうか

    // 確認ボタンを押せるかどうか（マス目を選んでて、エラーがなくて、ゲーム中の時だけ）
    var canConfirm: Bool {
        testModel.selectedPosition != nil && !testModel.showError && gameState == .inProgress
    }

    // MARK: - Initializer
    // TestViewModelを作る時の初期設定
    init(
        timerService: TimerServiceProtocol = TimerService(),
        dataService: DataServiceProtocol = DataService()
    ) {
        self.timerService = timerService
        self.dataService = dataService
        setupTimerObservation()  // タイマーの変化を監視する設定
    }

    // MARK: - Public Methods
    // 検査を開始する
    func startTest() {
        testStartTime = Date()      // 開始時刻を記録
        testModel.startTest()       // TestModelに検査開始を指示
        timerService.start()        // タイマーを開始
    }

    // 検査をリセットする（全てを最初の状態に戻す）
    func resetTest() {
        timerService.reset()        // タイマーをリセット
        testModel.resetTest()       // TestModelをリセット
        elapsedTime = 0            // 経過時間を0に戻す
        testStartTime = nil        // 開始時刻をクリア
    }

    // ユーザーがマス目をタップした時の処理
    func tapNumber(at row: Int, col: Int) {
        // TestModelにタップを伝える（選択状態にするだけ）
        let success = testModel.tapNumber(at: row, col: col)
        let tappedNumber = testModel.getNumber(at: row, col: col)
        print("Tapped (\(row),\(col)): \(tappedNumber), Selected: \(success)")  // デバッグ用
    }

    // 確認ボタンを押した時の処理
    // 戻り値：検査が全部終わったかどうか（true=終わった、false=まだ続く）
    func confirmSelectionWithResult() -> Bool {
        let completed = testModel.confirmSelection()  // TestModelで正解かチェック

        if testModel.showError {
            // 間違えた場合
            print("Incorrect selection.")  // デバッグ用
            return false  // まだ続く
        } else if completed {
            // 全部終わった場合
            timerService.stop()  // タイマーを止める

            // 結果を保存する（非同期で実行）
            Task {
                await saveTestResult()
            }

            return true  // 終わったよ
        } else {
            // 正解で次に進む場合
            print("Correct! Moving to next number: \(testModel.currentNumber)")  // デバッグ用
            return false  // まだ続く
        }
    }

    // 検査を途中でやめる
    func stopTest() {
        timerService.stop()         // タイマーを止める
        testModel.resetTest()       // TestModelをリセット
        elapsedTime = 0            // 経過時間をリセット
        testStartTime = nil        // 開始時刻をクリア
    }

    // MARK: - Grid Helper Methods
    // 指定した位置のマス目の数字を取得（画面表示用）
    func getNumber(at row: Int, col: Int) -> Int {
        return testModel.getNumber(at: row, col: col)
    }

    // 指定した位置のマス目が選択されているかチェック（画面表示用）
    func isSelected(row: Int, col: Int) -> Bool {
        guard let selectedPos = testModel.selectedPosition else { return false }  // 何も選ばれてなければfalse
        return selectedPos.row == row && selectedPos.col == col  // 位置が一致すればtrue
    }

    // MARK: - Private Methods
    // 検査結果をファイルに保存する
    private func saveTestResult() async {
        guard let startTime = testStartTime else { return }  // 開始時刻がなければ何もしない

        // 結果データを作成
        let result = TestResult(
            startTime: startTime,      // いつ始めたか
            endTime: Date(),          // いつ終わったか
            completionTime: elapsedTime  // かかった時間
        )

        do {
            try await dataService.saveTestResult(result)  // DataServiceで保存
        } catch {
            print("Failed to save result: \(error)")     // 保存に失敗した場合のエラー表示
        }
    }

    // タイマーの変化を監視する設定（タイマーが変わったら画面の時間表示も更新される）
    private func setupTimerObservation() {
        timerService.elapsedTimePublisher          // タイマーサービスから時間の変化を受け取る
            .receive(on: DispatchQueue.main)       // メインスレッドで受け取る（画面更新のため）
            .assign(to: \.elapsedTime, on: self)   // 受け取った時間をelapsedTimeに代入
            .store(in: &cancellables)              // 監視を続けるための設定
    }
}
