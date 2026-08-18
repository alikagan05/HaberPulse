import SwiftUI
import CoreData

@main
struct HaberPulseApp: App {
    @ObservedObject private var langManager = LanguageManager.shared

    var body: some Scene {
        WindowGroup {
            RootTabView()
                .environment(
                    \.managedObjectContext,
                     AppEnvironment.shared.persistence.container.viewContext
                )
                .environment(\.locale, langManager.locale)
                .id(langManager.currentLanguageRaw)
        }
    }
}

struct RootTabView: View {
    var body: some View {
        TabView {
            FeedView()
                .tabItem {
                    Label(
                        NSLocalizedString("tab_feed", comment: ""),
                        systemImage: "newspaper"
                    )
                }

            SearchView()
                .tabItem {
                    Label(
                        NSLocalizedString("tab_search", comment: ""),
                        systemImage: "magnifyingglass"
                    )
                }

            BookmarksView()
                .tabItem {
                    Label(
                        NSLocalizedString("tab_bookmarks", comment: ""),
                        systemImage: "bookmark"
                    )
                }

            HistoryView()
                .tabItem {
                    Label(
                        NSLocalizedString("tab_history", comment: ""),
                        systemImage: "clock"
                    )
                }
        }
        .tint(Color.brandPrimary)
    }
}
