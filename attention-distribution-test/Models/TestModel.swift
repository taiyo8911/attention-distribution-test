//
//  TestModel.swift
//  attention-distribution-test
//
//  Created by Taiyo KOSHIBA on 2025/08/18.
//

import Foundation

// MARK: - Test Model
// 検査のデータと状態を管理するクラス（ゲームのルールブック的な役割）
struct TestModel {
    // MARK: - Game Progress
    private(set) var gameState: GameState = .notStarted      // ゲームの状態（始まってない、やってる、終わったなど）
    private(set) var currentNumber: Int = 0                  // 今押すべき数字（0から始まって1、2、3...と増えていく）
    private(set) var targetNumber: Int = 48                  // 最後に押す数字（48まで）

    // MARK: - Grid Configuration
    private(set) var gridSize: Int = 7                       // マス目のサイズ（7×7の49個）
    private(set) var gridNumbers: [[Int]] = []               // マス目の数字配置（二次元配列で保存）

    // MARK: - User Interaction
    private(set) var selectedPosition: GridPosition?         // 今選んでるマス目の位置
    private(set) var showError: Bool = false                 // 間違えた時にエラーを表示するかどうか

    // MARK: - Computed Properties
    // 全部の数字を押し終わったかどうかをチェック
    var isComplete: Bool {
        return currentNumber > targetNumber  // 49（48の次）になったら完了
    }

    // MARK: - Initializer
    // 最初にTestModelを作る時の設定
    init() {
        // 初期化時は空配列（まだマス目に数字を配置してない状態）
        gridNumbers = []
    }

    // MARK: - Grid Management
    // マス目に数字をランダムに配置する（ゲーム開始時に呼ばれる）
    mutating func generateGrid() {
        // 7x7の空のマス目を作る（全部0で埋める）
        gridNumbers = Array(repeating: Array(repeating: 0, count: gridSize), count: gridSize)

        // 真ん中のマス目（3,3）に必ず0を置く
        gridNumbers[3][3] = 0

        // 1から48までの数字をバラバラに並び替える
        var numbers = Array(1...48)
        numbers.shuffle()

        // 真ん中以外のマス目に数字を順番に配置していく
        var index = 0  // 配置する数字のインデックス
        for row in 0..<7 {      // 縦のマス目（0から6まで）
            for col in 0..<7 {  // 横のマス目（0から6まで）
                if row != 3 || col != 3 { // 真ん中以外の場合
                    gridNumbers[row][col] = numbers[index]  // 数字を配置
                    index += 1  // 次の数字へ
                }
            }
        }
    }

    // 指定した位置のマス目の数字を取得する
    func getNumber(at row: Int, col: Int) -> Int {
        // マス目の範囲をチェック（0〜6の間か、配列が空じゃないか）
        guard row >= 0, row < 7, col >= 0, col < 7,
              !gridNumbers.isEmpty,
              row < gridNumbers.count,
              col < gridNumbers[row].count else {
            return -1  // 範囲外なら-1を返す
        }
        return gridNumbers[row][col]  // その位置の数字を返す
    }

    // MARK: - Game State Management
    // 検査を開始する
    mutating func startTest() {
        gameState = .inProgress      // 状態を「やってる最中」に変更
        generateGrid()               // マス目に数字を配置
        currentNumber = 0            // 最初に押す数字は0
        selectedPosition = nil       // まだ何も選んでない状態
        showError = false           // エラーも表示してない状態
    }

    // 検査をリセットする（最初の状態に戻す）
    mutating func resetTest() {
        gameState = .notStarted      // 状態を「まだ始まってない」に戻す
        currentNumber = 0            // 押す数字を0に戻す
        selectedPosition = nil       // 選択をクリア
        showError = false           // エラーをクリア
        gridNumbers = []            // マス目を空にする
    }

    // 検査を完了状態にする
    mutating func completeTest() {
        gameState = .completed       // 状態を「完了」に変更
    }

    // MARK: - User Interaction
    // ユーザーがマス目をタップした時の処理
    mutating func tapNumber(at row: Int, col: Int) -> Bool {
        guard gameState == .inProgress else { return false }  // ゲーム中じゃなければ何もしない

        // タップしたマス目を選択状態にする（まだ正解かどうかは判定しない）
        selectedPosition = GridPosition(row: row, col: col)

        // エラー表示を消す（新しくマス目を選んだから）
        showError = false

        return true  // タップできたことを返す
    }

    // 確認ボタンを押した時の処理（正解かどうかをチェックして次に進む）
    // 戻り値：検査が全部終わったかどうか（true=終わった、false=まだ続く）
    mutating func confirmSelection() -> Bool {
        guard let position = selectedPosition else { return false }    // マス目が選ばれてなければ何もしない
        guard gameState == .inProgress else { return false }          // ゲーム中じゃなければ何もしない

        let selectedNumber = getNumber(at: position.row, col: position.col)  // 選んだマス目の数字を取得

        if selectedNumber == currentNumber {
            // 正解の場合の処理
            currentNumber += 1           // 次に押す数字を1つ増やす
            selectedPosition = nil       // 選択状態をクリア
            showError = false           // エラーをクリア

            // 全部終わったかチェック
            if currentNumber > targetNumber {  // 48を超えたら
                completeTest()               // 検査完了にする
                return true                  // 「終わったよ」を返す
            }
            return false  // 「まだ続くよ」を返す
        } else {
            // 不正解の場合の処理
            showError = true             // エラーメッセージを表示
            selectedPosition = nil       // 選択状態をクリア（もう一度選び直してもらう）
            return false                // 「まだ続くよ」を返す
        }
    }
}

// MARK: - Supporting Types
// マス目の位置を表すデータ（縦と横の番号）
struct GridPosition: Equatable {
    let row: Int  // 縦の位置（0〜6）
    let col: Int  // 横の位置（0〜6）
}
