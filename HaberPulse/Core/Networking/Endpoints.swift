import Foundation

enum Endpoints {
    static let apiKey   = Secrets.guardianAPIKey
    static let baseURL  = "https://content.guardianapis.com"
    static let pageSize = 20

    static let sources: [NewsSource] = [
        NewsSource(
            id: "all",
            name: "source_all",
            language: "all",
            feedURL: nil,
            defaultSection: "Gündem",
            iconName: "globe"
        ),
        NewsSource(
            id: "guardian",
            name: "The Guardian",
            language: "en",
            feedURL: nil,
            defaultSection: "world",
            iconName: "newspaper"
        ),
        NewsSource(
            id: "trt_gundem",
            name: "TRT Haber",
            language: "tr",
            feedURL: URL(string: "https://www.trthaber.com/gundem_articles.rss"),
            defaultSection: "Gündem",
            iconName: "flame"
        ),
        NewsSource(
            id: "bbcturkce",
            name: "BBC Türkçe",
            language: "tr",
            feedURL: URL(string: "https://feeds.bbci.co.uk/turkce/rss.xml"),
            defaultSection: "Dünya",
            iconName: "globe.europe.africa"
        ),
        NewsSource(
            id: "ntv_gundem",
            name: "NTV",
            language: "tr",
            feedURL: URL(string: "https://www.ntv.com.tr/gundem.rss"),
            defaultSection: "Gündem",
            iconName: "bolt"
        ),
        NewsSource(
            id: "webtekno",
            name: "Webtekno",
            language: "tr",
            feedURL: URL(string: "https://www.webtekno.com/rss.xml"),
            defaultSection: "Teknoloji",
            iconName: "cpu"
        ),
    ]

    static let sections: [(id: String, label: String)] = [
        ("", "all"),
        ("world", "world"),
        ("technology", "technology"),
        ("science", "science"),
        ("business", "business"),
        ("sport", "sport"),
        ("culture", "culture"),
        ("environment", "environment"),
        ("politics", "politics"),
        ("health", "health"),
        ("education", "education"),
    ]

    static func feed(
        section: String = "",
        page: Int = 1,
        fromDate: String? = nil,
        toDate: String? = nil
    ) -> URL? {
        build(
            query: "",
            section: section,
            page: page,
            fromDate: fromDate,
            toDate: toDate
        )
    }

    static func search(
        query: String,
        section: String = "",
        page: Int = 1,
        fromDate: String? = nil
    ) -> URL? {
        build(
            query: query,
            section: section,
            page: page,
            fromDate: fromDate,
            toDate: nil
        )
    }

    private static func build(
        query: String,
        section: String,
        page: Int,
        fromDate: String?,
        toDate: String?
    ) -> URL? {
        var components = URLComponents(string: "\(baseURL)/search")
        var items: [URLQueryItem] = [
            URLQueryItem(name: "api-key",   value: apiKey),
            URLQueryItem(name: "page",      value: "\(page)"),
            URLQueryItem(name: "page-size", value: "\(pageSize)"),
            URLQueryItem(name: "show-fields", value: "thumbnail,bodyText,trailText,byline,wordcount"),
            URLQueryItem(name: "order-by", value: "newest"),
        ]

        if !query.isEmpty   { items.append(.init(name: "q",         value: query)) }
        if !section.isEmpty { items.append(.init(name: "section",   value: section)) }
        if let from = fromDate { items.append(.init(name: "from-date", value: from)) }
        if let to   = toDate   { items.append(.init(name: "to-date",   value: to)) }

        components?.queryItems = items
        return components?.url
    }
}
