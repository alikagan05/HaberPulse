// DataOriantedContentReaderApp.swift
// DataOriantedContentReader
// App

import SwiftUI

@main
struct DataOriantedContentReaderApp: App {

    // MARK: - Dependencies
    private let env = AppEnvironment.shared

    // MARK: - Body
    var body: some Scene {
        WindowGroup {
            RootTabView()
                .environmentObject(env)
                .environment(\.managedObjectContext, env.persistence.container.viewContext)
        }
    }
}

// MARK: - Root Tab View

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
