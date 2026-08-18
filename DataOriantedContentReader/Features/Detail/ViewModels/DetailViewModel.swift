// DetailViewModel.swift
// DataOriantedContentReader
// Features → Detail → ViewModels

import Foundation

@MainActor
final class DetailViewModel: ObservableObject {

    // MARK: - Published
    @Published var isBookmarked = false

    // MARK: - Data
    let article: Article

    // MARK: - Dependencies
    private let persistence: PersistenceController

    // MARK: - Init
    init(article: Article, env: AppEnvironment = .shared) {
        self.article     = article
        self.persistence = env.persistence
        self.isBookmarked = persistence.isBookmarked(apiId: article.apiId)
    }

    // MARK: - Public Methods

    func onAppear() {
        persistence.markAsRead(article: article)
        isBookmarked = persistence.isBookmarked(apiId: article.apiId)
    }

    func toggleBookmark() {
        persistence.toggleBookmark(for: article)
        isBookmarked = persistence.isBookmarked(apiId: article.apiId)
    }

    var shareItems: [Any] {
        [article.webTitle, URL(string: article.webUrl) as Any].compactMap { $0 }
    }
}
