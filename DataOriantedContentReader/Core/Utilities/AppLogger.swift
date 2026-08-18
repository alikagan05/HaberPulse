import OSLog

enum AppLogger {
    static let network   = Logger(subsystem: "com.alikagan.HaberPulse", category: "Network")
    static let storage   = Logger(subsystem: "com.alikagan.HaberPulse", category: "Storage")
    static let viewModel = Logger(subsystem: "com.alikagan.HaberPulse", category: "ViewModel")
    static let general   = Logger(subsystem: "com.alikagan.HaberPulse", category: "General")
}
