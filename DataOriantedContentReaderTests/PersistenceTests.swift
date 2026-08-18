import XCTest
import CoreData
@testable import HaberPulse

final class PersistenceTests: XCTestCase {
    private var persistence: PersistenceController!

    override func setUpWithError() throws {
        persistence = PersistenceController(inMemory: true)
    }

    override func tearDownWithError() throws {
        persistence = nil
    }

    private func makeArticle(id: String = "test/\(UUID().uuidString)") -> Article {
        Article(
            apiId: id,
            webTitle: "Test Article",
            webUrl: "https://theguardian.com/\(id)",
            sectionName: "technology",
            webPublicationDate: Date(),
            fields: ArticleFields(bodyText: "Body text", thumbnail: nil, trailText: "Trail", byline: "Author"),
            sourceName: "The Guardian",
            isTurkish: false
        )
    }

    func test_bookmark_toggle_addsBookmark() {
        let article = makeArticle()
        XCTAssertFalse(persistence.isBookmarked(apiId: article.apiId))

        persistence.toggleBookmark(for: article)
        XCTAssertTrue(persistence.isBookmarked(apiId: article.apiId))
    }

    func test_bookmark_toggle_removesBookmark() {
        let article = makeArticle()
        persistence.toggleBookmark(for: article)
        XCTAssertTrue(persistence.isBookmarked(apiId: article.apiId))

        persistence.toggleBookmark(for: article)
        XCTAssertFalse(persistence.isBookmarked(apiId: article.apiId))
    }

    func test_markAsRead_savesEntry() {
        let article = makeArticle()
        persistence.markAsRead(article: article)

        let req = SavedArticle.fetchRequest()
        req.predicate = NSPredicate(format: "apiId == %@", article.apiId)
        let results = try? persistence.container.viewContext.fetch(req)
        XCTAssertEqual(results?.count, 1)
        XCTAssertNotNil(results?.first?.readAt)
    }

    func test_clearHistory_removesNonBookmarkedReadArticles() {
        let article1 = makeArticle(id: "test/history1")
        let article2 = makeArticle(id: "test/history2")

        persistence.markAsRead(article: article1)
        persistence.markAsRead(article: article2)
        persistence.toggleBookmark(for: article2)

        persistence.clearHistory()

        let req1 = SavedArticle.fetchRequest()
        req1.predicate = NSPredicate(format: "apiId == %@", article1.apiId)
        let count1 = (try? persistence.container.viewContext.count(for: req1)) ?? 0
        XCTAssertEqual(count1, 0)

        XCTAssertTrue(persistence.isBookmarked(apiId: article2.apiId))
    }

    func test_savedArticle_populateFromArticle() {
        let article = makeArticle(id: "test/populate")
        let ctx = persistence.container.viewContext
        let saved = SavedArticle(context: ctx)
        saved.populate(from: article)

        XCTAssertEqual(saved.apiId, article.apiId)
        XCTAssertEqual(saved.title, article.webTitle)
        XCTAssertEqual(saved.sectionName, article.sectionName)
        XCTAssertEqual(saved.webURL, article.webUrl)
    }

    func test_article_initFromSavedArticle_roundtrip() {
        let original = makeArticle(id: "test/roundtrip")
        let ctx = persistence.container.viewContext
        let saved = SavedArticle(context: ctx)
        saved.populate(from: original)
        saved.savedAt = Date()

        let restored = Article(from: saved)
        XCTAssertNotNil(restored)
        XCTAssertEqual(restored?.apiId, original.apiId)
        XCTAssertEqual(restored?.webTitle, original.webTitle)
    }

    func test_saveTranslation_persistsTranslation() {
        let article = makeArticle(id: "test/trans")
        persistence.saveTranslation(for: article, translatedTitle: "Türkçe Başlık", translatedBody: "Türkçe Gövde")

        let req = SavedArticle.fetchRequest()
        req.predicate = NSPredicate(format: "apiId == %@", article.apiId)
        let results = try? persistence.container.viewContext.fetch(req)
        XCTAssertEqual(results?.first?.translatedTitle, "Türkçe Başlık")
        XCTAssertEqual(results?.first?.translatedBody, "Türkçe Gövde")
    }
}
