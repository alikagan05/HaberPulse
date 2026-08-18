// Endpoints.swift
// DataOriantedContentReader
// Core → Networking

import Foundation

/// The Guardian Open Platform API endpoint builder.
/// Replace `apiKey` with your key from https://open-platform.theguardian.com/access/
enum Endpoints {

    // MARK: - Configuration
    static let apiKey   = Secrets.guardianAPIKey  // App/Secrets.swift (gitignored)
    static let baseURL  = "https://content.guardianapis.com"
    static let pageSize = 20

    // MARK: - Available Sections
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

    // MARK: - Endpoint Builders

    /// Fetches articles for the main feed with optional section filter.
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

    /// Searches articles by a text query.
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

    // MARK: - Private Builder
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
