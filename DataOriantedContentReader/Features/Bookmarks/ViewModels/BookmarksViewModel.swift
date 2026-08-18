// BookmarksViewModel.swift
// DataOriantedContentReader
// Features → Bookmarks → ViewModels

import Foundation
import CoreData

@MainActor
final class BookmarksViewModel: ObservableObject {

    // MARK: - Published
    @Published var bookmarkedArticles: [Article] = []

    // MARK: - Dependencies
    private let persistence: PersistenceController

    // MARK: - Init
    init(env: AppEnvironment = .shared) {
        self.persistence = env.persistence
    }

    // MARK: - Public Methods

    func loadBookmarks() {
        let req = SavedArticle.fetchRequest()
        req.predicate = NSPredicate(format: "isBookmarked == YES")
        req.sortDescriptors = [NSSortDescriptor(keyPath: \SavedArticle.savedAt, ascending: false)]
        let results = (try? persistence.container.viewContext.fetch(req)) ?? []
        bookmarkedArticles = results.compactMap { Article(from: $0) }
        AppLogger.viewModel.info("Bookmarks loaded: \(self.bookmarkedArticles.count)")
    }

    func removeBookmark(article: Article) {
        persistence.toggleBookmark(for: article)
        loadBookmarks()
    }

    func removeBookmarks(at offsets: IndexSet) {
        offsets.forEach { index in
            let article = bookmarkedArticles[index]
            persistence.toggleBookmark(for: article)
        }
        loadBookmarks()
    }
}
