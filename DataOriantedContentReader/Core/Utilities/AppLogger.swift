// AppLogger.swift
// DataOriantedContentReader
// Core → Utilities

import OSLog

enum AppLogger {
    // nonisolated(unsafe): SWIFT_DEFAULT_ACTOR_ISOLATION=MainActor build ayarını bypass eder.
    // static let güvenli (bir kez init edilir), unsafe erişim riski yok.
    nonisolated(unsafe) static let network   = Logger(subsystem: "DataOriantedContentReader", category: "Network")
    nonisolated(unsafe) static let storage   = Logger(subsystem: "DataOriantedContentReader", category: "Storage")
    nonisolated(unsafe) static let viewModel = Logger(subsystem: "DataOriantedContentReader", category: "ViewModel")
    nonisolated(unsafe) static let general   = Logger(subsystem: "DataOriantedContentReader", category: "General")
}
