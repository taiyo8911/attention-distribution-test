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

    // MARK: - Initializers
    init(
        startTime: Date,
        endTime: Date,
        completionTime: TimeInterval? = nil
    ) {
        self.id = UUID()
        self.date = endTime
        self.startTime = startTime
        self.endTime = endTime
        self.completionTime = completionTime ?? endTime.timeIntervalSince(startTime)
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

extension TestResult: Comparable {
    static func < (lhs: TestResult, rhs: TestResult) -> Bool {
        return lhs.completionTime < rhs.completionTime
    }
}

// MARK: - Computed Properties
extension TestResult {
    var isPersonalBest: Bool {
        // This would be determined by comparing with other results
        // Implementation would be handled by the HistoryViewModel
        return false
    }

    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd HH:mm"
        return formatter.string(from: date)
    }

    var formattedTime: String {
        return completionTime.formattedTime
    }

    var shortFormattedTime: String {
        let minutes = Int(completionTime) / 60
        let seconds = Int(completionTime) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

// MARK: - TimeInterval Extension for Formatting
extension TimeInterval {
    var formattedTime: String {
        let minutes = Int(self) / 60
        let seconds = Int(self) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    var shortFormattedTime: String {
        let minutes = Int(self) / 60
        let seconds = Int(self) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    // Legacy method for backward compatibility (with milliseconds)
    var detailedFormattedTime: String {
        let minutes = Int(self) / 60
        let seconds = Int(self) % 60
        let milliseconds = Int((self.truncatingRemainder(dividingBy: 1)) * 100)
        return String(format: "%02d:%02d:%02d", minutes, seconds, milliseconds)
    }
}
