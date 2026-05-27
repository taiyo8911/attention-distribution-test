//
//  TestAdvice.swift
//  attention-distribution-test
//
//  Created by Taiyo KOSHIBA on 2025/08/18.
//

import Foundation

// 検査のパフォーマンスを上げるためのワンポイントアドバイス集
enum TestAdvice {
    static let all: [String] = [
        String(localized: "Scan the whole grid rather than fixating on one spot."),
        String(localized: "The next number may be right next to the last one."),
        String(localized: "If you make a mistake, take a deep breath before continuing."),
        String(localized: "With practice, your eye movement becomes more efficient and your time improves."),
        String(localized: "Prioritize unscanned areas over re-checking the same spots."),
        String(localized: "Try scanning outward from the center in a radial pattern."),
        String(localized: "Relax your shoulders and stay calm."),
        String(localized: "Tension narrows your field of vision. Take a deep breath before starting."),
        String(localized: "When your score plateaus, prioritize accuracy over speed."),
        String(localized: "Attention drops when you are tired. Take a break before trying again."),
        String(localized: "Close your eyes briefly before the test to reset your focus."),
        String(localized: "Taking in a wide area at once matters more than moving your eyes quickly."),
        String(localized: "A little practice each day steadily improves your attention skills."),
        String(localized: "You do not need to memorize the layout. Calmly search one number at a time."),
        String(localized: "If you cannot find a number after a while, scan vertically and horizontally."),
        String(localized: "Make sure your hand or stylus does not cover the grid."),
        String(localized: "Spotting the next number ahead of time makes the search more efficient.")
    ]

    // ランダムに1つ取得する
    static func random() -> String {
        all.randomElement() ?? String(localized: "Stay calm.")
    }
}
