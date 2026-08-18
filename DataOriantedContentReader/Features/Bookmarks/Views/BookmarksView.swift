// BookmarksView.swift
// DataOriantedContentReader
// Features → Bookmarks → Views

import SwiftUI

struct BookmarksView: View {
    @StateObject private var vm = BookmarksViewModel()

    var body: some View {
        NavigationStack {
            Group {
                if vm.bookmarkedArticles.isEmpty {
                    EmptyStateView(
                        icon: "bookmark",
                        title: NSLocalizedString("bookmarks_empty_title", comment: ""),
                        subtitle: NSLocalizedString("bookmarks_empty_subtitle", comment: "")
                    )
                } else {
                    articleList
                }
            }
            .navigationTitle(NSLocalizedString("tab_bookmarks", comment: ""))
        }
        .onAppear { vm.loadBookmarks() }
    }

    private var articleList: some View {
        List {
            ForEach(vm.bookmarkedArticles) { article in
                NavigationLink(value: article) {
                    ArticleRowView(
                        article: article,
                        isBookmarked: true,
                        onBookmark: {
                            withAnimation { vm.removeBookmark(article: article) }
                        }
                    )
                }
                .buttonStyle(.plain)
            }
            .onDelete { offsets in
                withAnimation { vm.removeBookmarks(at: offsets) }
            }
            .listRowBackground(Color(.secondarySystemGroupedBackground))
            .listRowSeparator(.hidden)
        }
        .listStyle(.insetGrouped)
        .navigationDestination(for: Article.self) { article in
            ArticleDetailView(article: article)
        }
    }
}

#Preview {
    BookmarksView()
}
