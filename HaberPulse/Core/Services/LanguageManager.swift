import SwiftUI
import Combine

enum AppLanguage: String, CaseIterable, Identifiable {
    case turkish = "tr"
    case english = "en"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .turkish: return "Türkçe 🇹🇷"
        case .english: return "English 🇬🇧"
        }
    }

    var shortLabel: String {
        switch self {
        case .turkish: return "TR"
        case .english: return "EN"
        }
    }
}

@MainActor
final class LanguageManager: ObservableObject {
    static let shared = LanguageManager()

    @AppStorage("selected_app_language") var currentLanguageRaw: String = "tr" {
        didSet {
            objectWillChange.send()
        }
    }

    var currentLanguage: AppLanguage {
        get { AppLanguage(rawValue: currentLanguageRaw) ?? .turkish }
        set { currentLanguageRaw = newValue.rawValue }
    }

    var locale: Locale {
        Locale(identifier: currentLanguage.rawValue)
    }

    var isTurkish: Bool {
        currentLanguage == .turkish
    }

    func toggleLanguage() {
        currentLanguage = (currentLanguage == .turkish) ? .english : .turkish
    }
}
