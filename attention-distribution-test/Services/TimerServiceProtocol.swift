//
//  TimerService.swift
//  attention-distribution-test
//
//  Created by Taiyo KOSHIBA on 2025/08/18.
//

import Foundation

// MARK: - Timer Service Protocol
protocol TimerServiceProtocol: AnyObject {
    var elapsedTime: TimeInterval { get }
    var isRunning: Bool { get }
    var elapsedTimeStream: AsyncStream<TimeInterval> { get }

    func start()
    func stop()
    func reset()
}

// MARK: - Timer Service
final class TimerService: TimerServiceProtocol {

    // MARK: - Properties
    private(set) var elapsedTime: TimeInterval = 0
    private(set) var isRunning: Bool = false

    // MARK: - Private Properties
    private var startTime: Date?
    private var timerTask: Task<Void, Never>?
    private let continuation: AsyncStream<TimeInterval>.Continuation
    let elapsedTimeStream: AsyncStream<TimeInterval>

    // MARK: - Initializer
    init() {
        var continuation: AsyncStream<TimeInterval>.Continuation!
        self.elapsedTimeStream = AsyncStream { continuation = $0 }
        self.continuation = continuation
    }

    deinit {
        timerTask?.cancel()
        continuation.finish()
    }

    // MARK: - Public Methods
    func start() {
        guard !isRunning else { return }

        let startedAt = Date()
        startTime = startedAt
        isRunning = true

        timerTask = Task { [weak self] in
            while !Task.isCancelled {
                try? await Task.sleep(for: .milliseconds(100))
                guard let self, self.isRunning else { return }
                let elapsed = Date().timeIntervalSince(startedAt)
                self.elapsedTime = elapsed
                self.continuation.yield(elapsed)
            }
        }
    }

    func stop() {
        guard isRunning else { return }

        isRunning = false
        timerTask?.cancel()
        timerTask = nil
    }

    func reset() {
        timerTask?.cancel()
        timerTask = nil

        startTime = nil
        elapsedTime = 0
        isRunning = false
        continuation.yield(0)
    }
}

// MARK: - Mock Timer Service (for testing/previews)
final class MockTimerService: TimerServiceProtocol {
    private(set) var elapsedTime: TimeInterval = 0
    private(set) var isRunning: Bool = false

    private var timerTask: Task<Void, Never>?
    private let continuation: AsyncStream<TimeInterval>.Continuation
    let elapsedTimeStream: AsyncStream<TimeInterval>

    init() {
        var continuation: AsyncStream<TimeInterval>.Continuation!
        self.elapsedTimeStream = AsyncStream { continuation = $0 }
        self.continuation = continuation
    }

    deinit {
        timerTask?.cancel()
        continuation.finish()
    }

    func start() {
        guard !isRunning else { return }
        isRunning = true

        timerTask = Task { [weak self] in
            while !Task.isCancelled {
                try? await Task.sleep(for: .milliseconds(100))
                guard let self, self.isRunning else { return }
                self.elapsedTime += 0.1
                self.continuation.yield(self.elapsedTime)
            }
        }
    }

    func stop() {
        isRunning = false
        timerTask?.cancel()
        timerTask = nil
    }

    func reset() {
        stop()
        elapsedTime = 0
        continuation.yield(0)
    }
}
