// AppLogger.swift
// DataOriantedContentReader
// Core → Utilities

import OSLog

enum AppLogger {
    static let network   = Logger(subsystem: "DataOriantedContentReader", category: "Network")
    static let storage   = Logger(subsystem: "DataOriantedContentReader", category: "Storage")
    static let viewModel = Logger(subsystem: "DataOriantedContentReader", category: "ViewModel")
    static let general   = Logger(subsystem: "DataOriantedContentReader", category: "General")
}
