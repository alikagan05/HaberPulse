import Foundation
import OSLog

struct NewsSource: Identifiable, Hashable {
    let id: String
    let name: String
    let language: String
    let feedURL: URL?
    let defaultSection: String
    let iconName: String

    var isTurkish: Bool { language == "tr" }
}

actor RSSClient {
    static let shared = RSSClient()

    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    func fetchRSS(from url: URL, sourceName: String, sectionName: String) async throws -> [Article] {
        AppLogger.network.info("→ RSS GET \(url.absoluteString)")

        let (data, response) = try await session.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.requestFailed(statusCode: (response as? HTTPURLResponse)?.statusCode ?? 500)
        }

        let parser = RSSParser(sourceName: sourceName, defaultSection: sectionName)
        return parser.parse(data: data)
    }
}

private final class RSSParser: NSObject, XMLParserDelegate {
    private let sourceName: String
    private let defaultSection: String
    private var articles: [Article] = []

    private var currentElement = ""
    private var currentTitle = ""
    private var currentLink = ""
    private var currentDescription = ""
    private var currentPubDateString = ""
    private var currentCategory = ""
    private var currentThumbnailURL: String?

    private let rfc822Formatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "EEE, dd MMM yyyy HH:mm:ss Z"
        df.locale = Locale(identifier: "en_US_POSIX")
        return df
    }()

    private let rfc822FormatterAlt: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "EEE, dd MMM yyyy HH:mm:ss zzz"
        df.locale = Locale(identifier: "en_US_POSIX")
        return df
    }()

    private let isoFormatter = ISO8601DateFormatter()

    init(sourceName: String, defaultSection: String) {
        self.sourceName = sourceName
        self.defaultSection = defaultSection
        super.init()
    }

    func parse(data: Data) -> [Article] {
        articles.removeAll()
        let xmlParser = XMLParser(data: data)
        xmlParser.delegate = self
        xmlParser.shouldProcessNamespaces = true
        xmlParser.parse()
        return articles
    }

    func parser(
        _ parser: XMLParser,
        didStartElement elementName: String,
        namespaceURI: String?,
        qualifiedName qName: String?,
        attributes attributeDict: [String : String] = [:]
    ) {
        currentElement = elementName.lowercased()

        if currentElement == "item" || currentElement == "entry" {
            currentTitle = ""
            currentLink = ""
            currentDescription = ""
            currentPubDateString = ""
            currentCategory = ""
            currentThumbnailURL = nil
        }

        if currentElement == "enclosure", let type = attributeDict["type"], type.hasPrefix("image/"), let url = attributeDict["url"] {
            currentThumbnailURL = url
        } else if (currentElement == "media:content" || currentElement == "content") && attributeDict["url"] != nil {
            if let url = attributeDict["url"] {
                currentThumbnailURL = url
            }
        } else if (currentElement == "media:thumbnail" || currentElement == "thumbnail"), let url = attributeDict["url"] {
            currentThumbnailURL = url
        }
    }

    func parser(_ parser: XMLParser, foundCharacters string: String) {
        let trimmed = string.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        switch currentElement {
        case "title":
            currentTitle += string
        case "link":
            currentLink += string
        case "description", "summary":
            currentDescription += string
        case "pubdate", "published", "updated", "dc:date":
            currentPubDateString += string
        case "category":
            currentCategory += string
        default:
            break
        }
    }

    func parser(
        _ parser: XMLParser,
        didEndElement elementName: String,
        namespaceURI: String?,
        qualifiedName qName: String?
    ) {
        let element = elementName.lowercased()
        if element == "item" || element == "entry" {
            let cleanTitle = currentTitle.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !cleanTitle.isEmpty else { return }

            let cleanLink = currentLink.trimmingCharacters(in: .whitespacesAndNewlines)
            let linkURL = cleanLink.isEmpty ? UUID().uuidString : cleanLink
            let parsedDate = parseDate(from: currentPubDateString.trimmingCharacters(in: .whitespacesAndNewlines))
            let category = currentCategory.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                ? defaultSection
                : currentCategory.trimmingCharacters(in: .whitespacesAndNewlines)

            let cleanDesc = currentDescription.strippingHTML()

            var thumb = currentThumbnailURL
            if thumb == nil {
                thumb = extractImageURL(from: currentDescription)
            }

            let article = Article(
                apiId: linkURL,
                webTitle: cleanTitle,
                webUrl: cleanLink,
                sectionName: category,
                webPublicationDate: parsedDate,
                fields: ArticleFields(
                    bodyText: cleanDesc,
                    thumbnail: thumb,
                    trailText: cleanDesc,
                    byline: sourceName
                ),
                sourceName: sourceName,
                isTurkish: true
            )

            articles.append(article)
        }
    }

    private func parseDate(from string: String) -> Date {
        if let date = rfc822Formatter.date(from: string) { return date }
        if let date = rfc822FormatterAlt.date(from: string) { return date }
        if let date = isoFormatter.date(from: string) { return date }
        return Date()
    }

    private func extractImageURL(from html: String) -> String? {
        guard let regex = try? NSRegularExpression(pattern: #"<img[^>]+src=["']([^"']+)["']"#, options: .caseInsensitive) else {
            return nil
        }
        let range = NSRange(location: 0, length: html.utf16.count)
        guard let match = regex.firstMatch(in: html, options: [], range: range),
              let urlRange = Range(match.range(at: 1), in: html) else {
            return nil
        }
        return String(html[urlRange])
    }
}
