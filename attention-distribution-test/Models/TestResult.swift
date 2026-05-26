//
//  TestResult.swift
//  attention-distribution-test
//
//  Created by Taiyo KOSHIBA on 2025/08/18.
//

import Foundation

// MARK: - Test Result Data Model
struct TestResult {
    let id: UUID
    let date: Date
    let completionTime: TimeInterval
    let startTime: Date
    let endTime: Date

    // MARK: - Initializer
    init(
        startTime: Date,
        endTime: Date,
        completionTime: TimeInterval
    ) {
        self.id = UUID()
        self.date = endTime
        self.startTime = startTime
        self.endTime = endTime
        self.completionTime = completionTime
    }
}

// MARK: - TestResult Extensions
extension TestResult: Codable {}

extension TestResult: Identifiable {}

extension TestResult: Equatable {
    static func == (lhs: TestResult, rhs: TestResult) -> Bool {
        return lhs.id == rhs.id
    }
}

// MARK: - Computed Properties
extension TestResult {
    // DateFormatterはコストが高いので共有インスタンスを使う
    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd HH:mm"
        return formatter
    }()

    var formattedDate: String {
        return Self.dateFormatter.string(from: date)
    }

    var formattedTime: String {
        return completionTime.formattedTime
    }
}

// MARK: - TimeInterval Extension for Formatting
extension TimeInterval {
    var formattedTime: String {
        let minutes = Int(self) / 60
        let seconds = Int(self) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
