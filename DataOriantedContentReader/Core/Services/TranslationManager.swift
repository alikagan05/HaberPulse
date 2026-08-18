import Foundation
import Combine
import OSLog
import CoreData
#if canImport(Translation)
import Translation
#endif

@MainActor
final class TranslationManager: ObservableObject {
    static let shared = TranslationManager()

    @Published var isTranslating: Bool = false
    @Published var translationError: String? = nil

    private let persistence = PersistenceController.shared

    func cachedTranslation(for article: Article) -> (title: String?, body: String?)? {
        let req = SavedArticle.fetchRequest()
        req.predicate = NSPredicate(format: "apiId == %@", article.apiId)
        req.fetchLimit = 1

        if let saved = (try? persistence.container.viewContext.fetch(req))?.first,
           let title = saved.translatedTitle, !title.isEmpty {
            return (title: title, body: saved.translatedBody)
        }
        return nil
    }

    func cacheTranslation(for article: Article, title: String, body: String?) {
        persistence.saveTranslation(for: article, translatedTitle: title, translatedBody: body)
        AppLogger.storage.info("Saved translation for article: \(article.apiId)")
    }
}
