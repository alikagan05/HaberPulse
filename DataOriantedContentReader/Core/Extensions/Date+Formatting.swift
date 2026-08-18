import Foundation

extension Date {
    var longFormatted: String {
        formatted(.dateTime.day().month(.wide).year())
    }

    var shortFormatted: String {
        formatted(.dateTime.day().month(.abbreviated).year())
    }

    var relativeFormatted: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: self, relativeTo: Date())
    }

    var timeFormatted: String {
        formatted(.dateTime.hour().minute())
    }

    var apiFormatted: String {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        f.locale = Locale(identifier: "en_US_POSIX")
        return f.string(from: self)
    }

    static func daysAgo(_ n: Int) -> Date {
        Calendar.current.date(byAdding: .day, value: -n, to: Date()) ?? Date()
    }
}
