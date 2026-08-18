// Date+Formatting.swift
// DataOriantedContentReader
// Core → Extensions

import Foundation

extension Date {

    /// "15 Ağustos 2025" formatında yerelleştirilmiş uzun tarih.
    var longFormatted: String {
        formatted(.dateTime.day().month(.wide).year())
    }

    /// "15 Ağu 2025" — kısa format.
    var shortFormatted: String {
        formatted(.dateTime.day().month(.abbreviated).year())
    }

    /// "3 saat önce", "2 gün önce" vb. göreceli süre.
    var relativeFormatted: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: self, relativeTo: Date())
    }

    /// "ss:dd" formatında saat.
    var timeFormatted: String {
        formatted(.dateTime.hour().minute())
    }

    /// API için "yyyy-MM-dd" formatı.
    var apiFormatted: String {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        f.locale = Locale(identifier: "en_US_POSIX")
        return f.string(from: self)
    }

    /// Bugünden N gün öncesine ait Date.
    static func daysAgo(_ n: Int) -> Date {
        Calendar.current.date(byAdding: .day, value: -n, to: Date()) ?? Date()
    }
}
