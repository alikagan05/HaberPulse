import XCTest
@testable import HaberPulse

@MainActor
final class FeedViewModelTests: XCTestCase {
    private func makeArticle(id: String = "test/1", section: String = "technology", source: String = "The Guardian") -> Article {
        Article(
            apiId: id,
            webTitle: "Test Başlığı",
            webUrl: "https://theguardian.com/\(id)",
            sectionName: section,
            webPublicationDate: Date(),
            fields: ArticleFields(
                bodyText: "Bu bir test makalesidir ve yeterli kelime sayısına sahiptir.",
                thumbnail: nil,
                trailText: "Kısa özet",
                byline: "Test Yazar"
            ),
            sourceName: source,
            isTurkish: source != "The Guardian"
        )
    }

    func test_article_estimatedReadTime_atLeastOne() {
        let article = makeArticle()
        XCTAssertGreaterThanOrEqual(article.estimatedReadTime, 1)
    }

    func test_article_cleanTrailText_stripsHTML() {
        let article = Article(
            apiId: "test/html",
            webTitle: "HTML Test",
            webUrl: "https://example.com",
            sectionName: "tech",
            webPublicationDate: Date(),
            fields: ArticleFields(
                bodyText: nil,
                thumbnail: nil,
                trailText: "<p>Clean <b>text</b></p>",
                byline: nil
            )
        )
        XCTAssertFalse(article.cleanTrailText.contains("<p>"))
    }

    func test_article_thumbnailURL_nil_whenNoThumbnail() {
        let article = makeArticle()
        XCTAssertNil(article.thumbnailURL)
    }

    func test_article_thumbnailURL_valid() {
        let urlString = "https://media.guim.co.uk/test.jpg"
        let article = Article(
            apiId: "test/thumb",
            webTitle: "Thumb Test",
            webUrl: "https://example.com",
            sectionName: "tech",
            webPublicationDate: Date(),
            fields: ArticleFields(bodyText: nil, thumbnail: urlString, trailText: nil, byline: nil)
        )
        XCTAssertEqual(article.thumbnailURL?.absoluteString, urlString)
    }

    func test_article_sourceName_and_isTurkish() {
        let trtArticle = makeArticle(id: "trt/1", source: "TRT Haber")
        XCTAssertEqual(trtArticle.sourceName, "TRT Haber")
        XCTAssertTrue(trtArticle.isTurkish)

        let guardianArticle = makeArticle(id: "guard/1", source: "The Guardian")
        XCTAssertEqual(guardianArticle.sourceName, "The Guardian")
        XCTAssertFalse(guardianArticle.isTurkish)
    }

    func test_string_isBlank_trueForEmpty() {
        XCTAssertTrue("".isBlank)
        XCTAssertTrue("   ".isBlank)
        XCTAssertTrue("\n".isBlank)
    }

    func test_string_isBlank_falseForContent() {
        XCTAssertFalse("Hello".isBlank)
    }

    func test_string_estimatedReadTime_minimum1() {
        XCTAssertEqual("".estimatedReadTimeMinutes, 1)
        XCTAssertEqual("one".estimatedReadTimeMinutes, 1)
    }

    func test_date_apiFormatted_correctFormat() {
        var components = DateComponents()
        components.year  = 2025
        components.month = 8
        components.day   = 15
        let date = Calendar.current.date(from: components)!
        XCTAssertEqual(date.apiFormatted, "2025-08-15")
    }

    func test_date_daysAgo_inPast() {
        let past = Date.daysAgo(7)
        XCTAssertLessThan(past, Date())
    }
}
