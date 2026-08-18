import Foundation
import Combine

@MainActor
final class DetailViewModel: ObservableObject {
    @Published var isBookmarked = false
    @Published var isShowingTranslation = false
    @Published var translatedTitle: String? = nil
    @Published var translatedBody: String? = nil

    let article: Article
    private let persistence: PersistenceController

    init(article: Article) {
        self.article      = article
        self.persistence  = AppEnvironment.shared.persistence
        self.isBookmarked = AppEnvironment.shared.persistence.isBookmarked(apiId: article.apiId)
    }

    func onAppear() {
        persistence.markAsRead(article: article)
        isBookmarked = persistence.isBookmarked(apiId: article.apiId)
        loadCachedTranslation()
    }

    func toggleBookmark() {
        persistence.toggleBookmark(for: article)
        isBookmarked = persistence.isBookmarked(apiId: article.apiId)
    }

    func toggleTranslationView() {
        isShowingTranslation.toggle()
    }

    func applyTranslation(title: String, body: String?) {
        translatedTitle      = title
        translatedBody       = body
        isShowingTranslation = true
        persistence.saveTranslation(for: article, translatedTitle: title, translatedBody: body)
    }

    private func loadCachedTranslation() {
        if let cached = TranslationManager.shared.cachedTranslation(for: article) {
            translatedTitle      = cached.title
            translatedBody       = cached.body
            if LanguageManager.shared.isTurkish && !article.isTurkish {
                isShowingTranslation = true
            }
        }
    }

    var shareURL: URL {
        URL(string: article.webUrl) ?? URL(string: "https://theguardian.com")!
    }
}
