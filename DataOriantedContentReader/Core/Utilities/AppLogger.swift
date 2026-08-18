// AppLogger.swift
// DataOriantedContentReader
// Core → Utilities

import OSLog

enum AppLogger {
    private static let subsystem = Bundle.main.bundleIdentifier ?? "com.app.DataOriantedContentReader"

    static let network   = Logger(subsystem: subsystem, category: "Network")
    static let storage   = Logger(subsystem: subsystem, category: "Storage")
    static let viewModel = Logger(subsystem: subsystem, category: "ViewModel")
    static let general   = Logger(subsystem: subsystem, category: "General")
}
