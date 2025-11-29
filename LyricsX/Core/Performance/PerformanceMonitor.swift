//
//  PerformanceMonitor.swift
//  LyricsX - https://github.com/ddddxxx/LyricsX
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import os.log
import os.signpost

// MARK: - Performance Monitor

/// An actor-based performance monitoring system using os_signpost.
///
/// Use this to measure and track performance of critical operations
/// such as lyrics search, parsing, and rendering.
///
/// Example usage:
/// ```swift
/// let lyrics = await PerformanceMonitor.shared.measure("fetchLyrics") {
///     try await service.fetchLyrics(for: track)
/// }
/// ```
@available(macOS 12.0, *)
public actor PerformanceMonitor {
    
    // MARK: - Shared Instance
    
    /// The shared performance monitor instance.
    public static let shared = PerformanceMonitor()
    
    // MARK: - Properties
    
    /// OSLog for performance logging.
    private let performanceLog = OSLog(
        subsystem: "com.ddddxxx.LyricsX",
        category: .pointsOfInterest
    )
    
    /// OSLog for general metrics.
    private let metricsLog = OSLog(
        subsystem: "com.ddddxxx.LyricsX",
        category: "Metrics"
    )
    
    /// Storage for performance metrics.
    private var metrics: [String: PerformanceMetric] = [:]
    
    /// Whether performance monitoring is enabled.
    private var isEnabled: Bool = true
    
    // MARK: - Initialization
    
    private init() {}
    
    // MARK: - Configuration
    
    /// Enables or disables performance monitoring.
    ///
    /// - Parameter enabled: Whether to enable monitoring.
    public func setEnabled(_ enabled: Bool) {
        isEnabled = enabled
    }
    
    // MARK: - Measurement Methods
    
    /// Measures the execution time of a synchronous operation.
    ///
    /// - Parameters:
    ///   - label: A descriptive label for the operation.
    ///   - operation: The operation to measure.
    /// - Returns: The result of the operation.
    public func measure<T>(
        _ label: String,
        operation: () throws -> T
    ) rethrows -> T {
        guard isEnabled else {
            return try operation()
        }
        
        let signpostID = OSSignpostID(log: performanceLog)
        os_signpost(.begin, log: performanceLog, name: "Operation", signpostID: signpostID, "%{public}s", label)
        
        let start = CFAbsoluteTimeGetCurrent()
        defer {
            let elapsed = CFAbsoluteTimeGetCurrent() - start
            let elapsedMs = elapsed * 1000
            
            os_signpost(.end, log: performanceLog, name: "Operation", signpostID: signpostID, "%{public}s: %.3fms", label, elapsedMs)
            
            Task {
                await recordMetric(label: label, duration: elapsed)
            }
        }
        
        return try operation()
    }
    
    /// Measures the execution time of an async operation.
    ///
    /// - Parameters:
    ///   - label: A descriptive label for the operation.
    ///   - operation: The async operation to measure.
    /// - Returns: The result of the operation.
    public func measure<T>(
        _ label: String,
        operation: () async throws -> T
    ) async rethrows -> T {
        guard isEnabled else {
            return try await operation()
        }
        
        let signpostID = OSSignpostID(log: performanceLog)
        os_signpost(.begin, log: performanceLog, name: "Operation", signpostID: signpostID, "%{public}s", label)
        
        let start = CFAbsoluteTimeGetCurrent()
        defer {
            let elapsed = CFAbsoluteTimeGetCurrent() - start
            let elapsedMs = elapsed * 1000
            
            os_signpost(.end, log: performanceLog, name: "Operation", signpostID: signpostID, "%{public}s: %.3fms", label, elapsedMs)
            
            Task {
                await recordMetric(label: label, duration: elapsed)
            }
        }
        
        return try await operation()
    }
    
    /// Begins an interval measurement.
    ///
    /// - Parameter label: A descriptive label for the interval.
    /// - Returns: A signpost ID to end the interval.
    public func beginInterval(_ label: String) -> OSSignpostID {
        let signpostID = OSSignpostID(log: performanceLog)
        if isEnabled {
            os_signpost(.begin, log: performanceLog, name: "Interval", signpostID: signpostID, "%{public}s", label)
        }
        return signpostID
    }
    
    /// Ends an interval measurement.
    ///
    /// - Parameters:
    ///   - label: The label used when beginning the interval.
    ///   - signpostID: The signpost ID returned by `beginInterval`.
    public func endInterval(_ label: String, signpostID: OSSignpostID) {
        if isEnabled {
            os_signpost(.end, log: performanceLog, name: "Interval", signpostID: signpostID, "%{public}s", label)
        }
    }
    
    /// Records an event marker in the performance timeline.
    ///
    /// - Parameters:
    ///   - label: A descriptive label for the event.
    ///   - message: An optional message with additional details.
    public func event(_ label: String, message: String? = nil) {
        guard isEnabled else { return }
        
        if let message = message {
            os_signpost(.event, log: performanceLog, name: "Event", "%{public}s: %{public}s", label, message)
        } else {
            os_signpost(.event, log: performanceLog, name: "Event", "%{public}s", label)
        }
    }
    
    // MARK: - Metrics Collection
    
    /// Records a performance metric.
    private func recordMetric(label: String, duration: TimeInterval) {
        var metric = metrics[label] ?? PerformanceMetric(label: label)
        metric.record(duration: duration)
        metrics[label] = metric
        
        // Log if threshold exceeded
        if duration > 0.5 { // 500ms threshold
            os_log(
                .info,
                log: metricsLog,
                "Performance warning: %{public}s took %.2fms",
                label,
                duration * 1000
            )
        }
    }
    
    /// Returns the collected metrics for a specific operation.
    ///
    /// - Parameter label: The operation label.
    /// - Returns: The performance metric, or nil if not recorded.
    public func getMetric(for label: String) -> PerformanceMetric? {
        metrics[label]
    }
    
    /// Returns all collected metrics.
    public func getAllMetrics() -> [PerformanceMetric] {
        Array(metrics.values)
    }
    
    /// Resets all collected metrics.
    public func resetMetrics() {
        metrics.removeAll()
    }
    
    /// Generates a performance report.
    ///
    /// - Returns: A formatted string with performance statistics.
    public func generateReport() -> String {
        var report = "=== LyricsX Performance Report ===\n\n"
        
        let sortedMetrics = metrics.values.sorted { $0.totalDuration > $1.totalDuration }
        
        for metric in sortedMetrics {
            report += """
            \(metric.label):
              Count: \(metric.count)
              Average: \(String(format: "%.2f", metric.averageDuration * 1000))ms
              Min: \(String(format: "%.2f", metric.minDuration * 1000))ms
              Max: \(String(format: "%.2f", metric.maxDuration * 1000))ms
              Total: \(String(format: "%.2f", metric.totalDuration * 1000))ms
            
            """
        }
        
        return report
    }
}

// MARK: - Performance Metric

/// A structure that collects performance statistics for a labeled operation.
public struct PerformanceMetric: Sendable {
    
    /// The operation label.
    public let label: String
    
    /// The number of times the operation was measured.
    public private(set) var count: Int = 0
    
    /// The total duration of all measured operations.
    public private(set) var totalDuration: TimeInterval = 0
    
    /// The minimum duration recorded.
    public private(set) var minDuration: TimeInterval = .infinity
    
    /// The maximum duration recorded.
    public private(set) var maxDuration: TimeInterval = 0
    
    /// The average duration of all measured operations.
    public var averageDuration: TimeInterval {
        guard count > 0 else { return 0 }
        return totalDuration / Double(count)
    }
    
    /// Records a new duration measurement.
    ///
    /// - Parameter duration: The duration to record.
    mutating func record(duration: TimeInterval) {
        count += 1
        totalDuration += duration
        minDuration = min(minDuration, duration)
        maxDuration = max(maxDuration, duration)
    }
}

// MARK: - Convenience Extensions

@available(macOS 12.0, *)
extension PerformanceMonitor {
    
    /// Pre-defined labels for common operations.
    public enum OperationLabel {
        public static let lyricsSearch = "lyrics.search"
        public static let lyricsParse = "lyrics.parse"
        public static let lyricsFetch = "lyrics.fetch"
        public static let lyricsCache = "lyrics.cache"
        public static let playerUpdate = "player.update"
        public static let overlayRender = "overlay.render"
        public static let appStartup = "app.startup"
        public static let viewAppear = "view.appear"
    }
}
