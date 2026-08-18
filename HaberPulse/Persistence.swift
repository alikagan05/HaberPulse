import CoreData
import OSLog

final class PersistenceController {
    static let shared = PersistenceController()

    @MainActor
    static let preview: PersistenceController = {
        let controller = PersistenceController(inMemory: true)
        let ctx = controller.container.viewContext
        let sample = SavedArticle(context: ctx)
        sample.apiId         = "preview/article/1"
        sample.title         = "SwiftUI ile Modern iOS Geliştirme"
        sample.sectionName   = "technology"
        sample.webURL        = "https://theguardian.com"
        sample.trailText     = "MVVM mimarisi ile güçlü bir iOS uygulaması nasıl geliştirilir?"
        sample.publishedAt   = Date()
        sample.savedAt       = Date()
        sample.isBookmarked  = true
        sample.estimatedReadTime = 4
        sample.sourceName    = "The Guardian"
        sample.translatedTitle = "Modern iOS Development with SwiftUI"
        try? ctx.save()
        return controller
    }()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "HaberPulse")
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores { _, error in
            if let error {
                AppLogger.storage.critical("Core Data load failed: \(error.localizedDescription)")
                fatalError("Core Data store failed to load: \(error)")
            }
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }

    func save() {
        let ctx = container.viewContext
        guard ctx.hasChanges else { return }
        do {
            try ctx.save()
            AppLogger.storage.info("Context saved.")
        } catch {
            AppLogger.storage.error("Save failed: \(error.localizedDescription)")
        }
    }

    func isBookmarked(apiId: String) -> Bool {
        let req = SavedArticle.fetchRequest()
        req.predicate = NSPredicate(format: "apiId == %@ AND isBookmarked == YES", apiId)
        req.fetchLimit = 1
        return (try? container.viewContext.count(for: req)) ?? 0 > 0
    }

    func toggleBookmark(for article: Article) {
        let ctx = container.viewContext
        let req = SavedArticle.fetchRequest()
        req.predicate = NSPredicate(format: "apiId == %@", article.apiId)
        req.fetchLimit = 1

        if let existing = (try? ctx.fetch(req))?.first {
            if existing.isBookmarked {
                if existing.readAt != nil {
                    existing.isBookmarked = false
                } else {
                    ctx.delete(existing)
                }
            } else {
                existing.isBookmarked = true
            }
        } else {
            let saved = SavedArticle(context: ctx)
            saved.populate(from: article)
            saved.savedAt       = Date()
            saved.isBookmarked  = true
        }
        save()
    }

    func markAsRead(article: Article) {
        let ctx = container.viewContext
        let req = SavedArticle.fetchRequest()
        req.predicate = NSPredicate(format: "apiId == %@", article.apiId)
        req.fetchLimit = 1

        if let existing = (try? ctx.fetch(req))?.first {
            existing.readAt = Date()
        } else {
            let saved = SavedArticle(context: ctx)
            saved.populate(from: article)
            saved.savedAt      = Date()
            saved.readAt       = Date()
            saved.isBookmarked = false
        }
        save()
    }

    func saveTranslation(for article: Article, translatedTitle: String?, translatedBody: String?) {
        let ctx = container.viewContext
        let req = SavedArticle.fetchRequest()
        req.predicate = NSPredicate(format: "apiId == %@", article.apiId)
        req.fetchLimit = 1

        let target: SavedArticle
        if let existing = (try? ctx.fetch(req))?.first {
            target = existing
        } else {
            target = SavedArticle(context: ctx)
            target.populate(from: article)
            target.savedAt = Date()
        }
        target.translatedTitle = translatedTitle
        target.translatedBody  = translatedBody
        save()
    }

    func clearHistory() {
        let ctx = container.viewContext
        let req = SavedArticle.fetchRequest()
        req.predicate = NSPredicate(format: "isBookmarked == NO AND readAt != nil")
        let results = (try? ctx.fetch(req)) ?? []
        results.forEach { ctx.delete($0) }
        save()
    }
}
