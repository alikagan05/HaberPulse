// DetailViewModel.swift
// DataOriantedContentReader
// Features → Detail → ViewModels

import Foundation
import Combine

@MainActor
final class DetailViewModel: ObservableObject {

    // MARK: - Published
    @Published var isBookmarked = false

    // MARK: - Data
    let article: Article

    // MARK: - Dependencies
    private let persistence: PersistenceController

    // MARK: - Init
    init(article: Article) {
        self.article     = article
        self.persistence = AppEnvironment.shared.persistence
        self.isBookmarked = AppEnvironment.shared.persistence.isBookmarked(apiId: article.apiId)
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

    var shareURL: URL {
        URL(string: article.webUrl) ?? URL(string: "https://theguardian.com")!
    }
}
