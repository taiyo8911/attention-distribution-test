//
//  TestResult.swift
//  attention-distribution-test
//
//  Created by Taiyo KOSHIBA on 2025/08/18.
//

import Foundation
import UIKit

// MARK: - Test Result Data Model
struct TestResult {
    let id: UUID
    let date: Date
    let completionTime: TimeInterval
    let deviceType: DeviceType
    let deviceModel: String
    let appVersion: String
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
        self.deviceType = DeviceType.current
        self.deviceModel = UIDevice.current.model
        self.appVersion = Bundle.main.appVersion
    }
    
    // Legacy initializer for backward compatibility
    init(date: Date, completionTime: TimeInterval, deviceType: String) {
        self.id = UUID()
        self.date = date
        self.completionTime = completionTime
        self.deviceType = DeviceType(rawValue: deviceType) ?? .unknown
        self.deviceModel = UIDevice.current.model
        self.appVersion = Bundle.main.appVersion
        self.startTime = date.addingTimeInterval(-completionTime)
        self.endTime = date
    }
}

// MARK: - Device Type Enumeration
enum DeviceType: String, CaseIterable {
    case iPhone = "iPhone"
    case iPad = "iPad"
    case unknown = "Unknown"
    
    static var current: DeviceType {
        switch UIDevice.current.userInterfaceIdiom {
        case .phone:
            return .iPhone
        case .pad:
            return .iPad
        default:
            return .unknown
        }
    }
    
    var displayName: String {
        return rawValue
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

// MARK: - Bundle Extension for App Version
private extension Bundle {
    var appVersion: String {
        return infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
    }
}

// MARK: - TimeInterval Extension for Formatting
extension TimeInterval {
    var formattedTime: String {
        let minutes = Int(self) / 60
        let seconds = Int(self) % 60
        let milliseconds = Int((self.truncatingRemainder(dividingBy: 1)) * 100)
        return String(format: "%02d:%02d:%02d", minutes, seconds, milliseconds)
    }
    
    var shortFormattedTime: String {
        let minutes = Int(self) / 60
        let seconds = Int(self) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}