import Foundation
import Combine
import CoreData
import OSLog

@MainActor
final class HistoryViewModel: ObservableObject {
    @Published var readArticles: [Article] = []
    @Published var showClearAlert = false

    private let persistence: PersistenceController

    init() {
        self.persistence = AppEnvironment.shared.persistence
    }

    func loadHistory() {
        let req = SavedArticle.fetchRequest()
        req.predicate = NSPredicate(format: "readAt != nil")
        req.sortDescriptors = [NSSortDescriptor(keyPath: \SavedArticle.readAt, ascending: false)]
        let results = (try? persistence.container.viewContext.fetch(req)) ?? []
        readArticles = results.compactMap { Article(from: $0) }
        AppLogger.viewModel.info("History loaded: \(self.readArticles.count) articles")
    }

    func clearHistory() {
        persistence.clearHistory()
        readArticles = readArticles.filter {
            persistence.isBookmarked(apiId: $0.apiId)
        }
    }

    func readDate(for article: Article) -> Date? {
        let req = SavedArticle.fetchRequest()
        req.predicate = NSPredicate(format: "apiId == %@", article.apiId)
        req.fetchLimit = 1
        return (try? persistence.container.viewContext.fetch(req))?.first?.readAt
    }
}
