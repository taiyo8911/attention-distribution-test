//
//  TimerService.swift
//  attention-distribution-test
//
//  Created by Taiyo KOSHIBA on 2025/08/18.
//

import Foundation
import Combine
import QuartzCore

// MARK: - Timer Service Protocol
protocol TimerServiceProtocol {
    var elapsedTime: TimeInterval { get }
    var isRunning: Bool { get }
    var elapsedTimePublisher: AnyPublisher<TimeInterval, Never> { get }

    func start()
    func stop()
    func pause()
    func resume()
    func reset()
}

// MARK: - High-Precision Timer Service
class TimerService: ObservableObject, TimerServiceProtocol {

    // MARK: - Published Properties
    @Published private(set) var elapsedTime: TimeInterval = 0
    @Published private(set) var isRunning: Bool = false

    // MARK: - Private Properties
    private var startTime: Date?
    private var pauseTime: Date?
    private var totalPauseTime: TimeInterval = 0
    private var timer: Timer?
    private var displayLink: CADisplayLink?

    // High precision timing
    private let updateInterval: TimeInterval = 0.001 // 1ms precision
    private var lastUpdateTime: CFTimeInterval = 0

    // MARK: - Publishers
    var elapsedTimePublisher: AnyPublisher<TimeInterval, Never> {
        $elapsedTime.eraseToAnyPublisher()
    }

    // MARK: - Initializer
    init() {
        setupDisplayLink()
    }

    deinit {
        cleanupTimer()
        cleanupDisplayLink()
    }

    // MARK: - Public Methods
    func start() {
        guard !isRunning else { return }

        startTime = Date()
        pauseTime = nil
        totalPauseTime = 0
        isRunning = true

        startHighPrecisionTimer()

        print("Timer started at: \(startTime!)")
    }

    func stop() {
        guard isRunning else { return }

        isRunning = false
        cleanupTimer()

        print("Timer stopped. Final time: \(elapsedTime)")
    }

    func pause() {
        guard isRunning && pauseTime == nil else { return }

        pauseTime = Date()
        cleanupTimer()

        print("Timer paused at: \(elapsedTime)")
    }

    func resume() {
        guard isRunning && pauseTime != nil else { return }

        if let pauseStart = pauseTime {
            totalPauseTime += Date().timeIntervalSince(pauseStart)
            pauseTime = nil
        }

        startHighPrecisionTimer()

        print("Timer resumed. Total pause time: \(totalPauseTime)")
    }

    func reset() {
        cleanupTimer()

        startTime = nil
        pauseTime = nil
        totalPauseTime = 0
        elapsedTime = 0
        isRunning = false

        print("Timer reset")
    }

    // MARK: - Private Methods
    private func setupDisplayLink() {
        // CADisplayLink for ultra-high precision on main thread
        displayLink = CADisplayLink(target: self, selector: #selector(displayLinkUpdate))
        displayLink?.preferredFramesPerSecond = 60 // 60 FPS for smooth updates
    }

    private func startHighPrecisionTimer() {
        // Use both Timer and CADisplayLink for maximum precision

        // Primary timer for regular updates
        timer = Timer.scheduledTimer(withTimeInterval: updateInterval, repeats: true) { [weak self] _ in
            self?.updateElapsedTime()
        }

        // CADisplayLink for display synchronization
        displayLink?.add(to: .current, forMode: .common)
        lastUpdateTime = CACurrentMediaTime()
    }

    @objc private func displayLinkUpdate() {
        guard isRunning && pauseTime == nil else { return }

        let currentTime = CACurrentMediaTime()
        if currentTime - lastUpdateTime >= updateInterval {
            updateElapsedTime()
            lastUpdateTime = currentTime
        }
    }

    private func updateElapsedTime() {
        guard let startTime = startTime else { return }
        guard isRunning else { return }

        let currentTime = Date()
        let totalTime = currentTime.timeIntervalSince(startTime)

        var pauseAdjustment = totalPauseTime
        if let pauseStart = pauseTime {
            pauseAdjustment += currentTime.timeIntervalSince(pauseStart)
        }

        elapsedTime = max(0, totalTime - pauseAdjustment)
    }

    private func cleanupTimer() {
        timer?.invalidate()
        timer = nil
        displayLink?.remove(from: .current, forMode: .common)
    }

    private func cleanupDisplayLink() {
        displayLink?.invalidate()
        displayLink = nil
    }
}

// MARK: - Timer State
extension TimerService {
    enum TimerState {
        case stopped
        case running
        case paused

        var description: String {
            switch self {
            case .stopped: return "停止"
            case .running: return "実行中"
            case .paused: return "一時停止"
            }
        }
    }

    var state: TimerState {
        if !isRunning {
            return .stopped
        } else if pauseTime != nil {
            return .paused
        } else {
            return .running
        }
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

    func pause() {
        timer?.invalidate()
        timer = nil
    }

    func resume() {
        guard isRunning else { return }
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            self.elapsedTime += 0.1
        }
    }

    func reset() {
        stop()
        elapsedTime = 0
    }
}
