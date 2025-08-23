//
//  TimerService.swift
//  attention-distribution-test
//
//  Created by Taiyo KOSHIBA on 2025/08/18.
//

import Foundation
import Combine

// MARK: - Timer Service Protocol
protocol TimerServiceProtocol {
    var elapsedTime: TimeInterval { get }
    var isRunning: Bool { get }
    var elapsedTimePublisher: AnyPublisher<TimeInterval, Never> { get }

    func start()
    func stop()
    func reset()
}

// MARK: - Timer Service
class TimerService: ObservableObject, TimerServiceProtocol {

    // MARK: - Published Properties
    @Published private(set) var elapsedTime: TimeInterval = 0
    @Published private(set) var isRunning: Bool = false

    // MARK: - Private Properties
    private var startTime: Date?
    private var timer: Timer?

    // MARK: - Publishers
    var elapsedTimePublisher: AnyPublisher<TimeInterval, Never> {
        $elapsedTime.eraseToAnyPublisher()
    }

    // MARK: - Initializer
    init() {}

    deinit {
        cleanupTimer()
    }

    // MARK: - Public Methods
    func start() {
        guard !isRunning else { return }

        startTime = Date()
        isRunning = true

        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            self?.updateElapsedTime()
        }

        print("Timer started at: \(startTime!)")
    }

    func stop() {
        guard isRunning else { return }

        isRunning = false
        cleanupTimer()

        print("Timer stopped. Final time: \(elapsedTime)")
    }

    func reset() {
        cleanupTimer()

        startTime = nil
        elapsedTime = 0
        isRunning = false

        print("Timer reset")
    }

    // MARK: - Private Methods
    private func updateElapsedTime() {
        guard let startTime = startTime, isRunning else { return }
        elapsedTime = Date().timeIntervalSince(startTime)
    }

    private func cleanupTimer() {
        timer?.invalidate()
        timer = nil
    }
}

// MARK: - Mock Timer Service (for testing/previews)
class MockTimerService: TimerServiceProtocol {
    @Published var elapsedTime: TimeInterval = 0
    @Published var isRunning: Bool = false

    var elapsedTimePublisher: AnyPublisher<TimeInterval, Never> {
        $elapsedTime.eraseToAnyPublisher()
    }

    private var timer: Timer?

    func start() {
        isRunning = true
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            self.elapsedTime += 0.1
        }
    }

    func stop() {
        isRunning = false
        timer?.invalidate()
        timer = nil
    }

    func reset() {
        stop()
        elapsedTime = 0
    }
}
