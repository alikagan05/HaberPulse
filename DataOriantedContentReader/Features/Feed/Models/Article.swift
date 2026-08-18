// Article.swift
// DataOriantedContentReader
// Features → Feed → Models

import Foundation

// MARK: - API Response Models

struct GuardianResponse: Decodable {
    let response: GuardianContent
}

struct GuardianContent: Decodable {
    let status: String
    let total: Int
    let currentPage: Int
    let pages: Int
    let results: [Article]
}

// MARK: - Article

struct Article: Identifiable, Decodable, Hashable {
    // Guardian API uses a path string as the ID, e.g. "technology/2025/aug/15/..."
    var id: String { apiId }
    let apiId: String
    let webTitle: String
    let webUrl: String
    let sectionName: String
    let webPublicationDate: Date
    let fields: ArticleFields?

    // MARK: Computed
    var estimatedReadTime: Int {
        let text = fields?.bodyText ?? fields?.trailText ?? ""
        return text.strippingHTML().estimatedReadTimeMinutes
    }

    var thumbnailURL: URL? {
        guard let str = fields?.thumbnail else { return nil }
        return URL(string: str)
    }

    var cleanTrailText: String {
        fields?.trailText?.strippingHTML() ?? ""
    }

    var displayByline: String {
        guard let byline = fields?.byline, !byline.isBlank else { return "" }
        return byline
    }

    // MARK: CodingKeys
    enum CodingKeys: String, CodingKey {
        case apiId = "id"
        case webTitle, webUrl, sectionName, webPublicationDate, fields
    }
}

// MARK: - ArticleFields

struct ArticleFields: Decodable, Hashable {
    let bodyText: String?
    let thumbnail: String?
    let trailText: String?
    let byline: String?
}

// MARK: - Core Data ↔ Article Conversion

extension Article {
    /// Creates an Article from a Core Data SavedArticle.
    init?(from saved: SavedArticle) {
        guard let apiId = saved.apiId as String?,
              let webTitle = saved.title as String?,
              let webUrl = saved.webURL as String?,
              let sectionName = saved.sectionName as String?,
              let publishedAt = saved.publishedAt as Date?
        else { return nil }

        self.apiId             = apiId
        self.webTitle          = webTitle
        self.webUrl            = webUrl
        self.sectionName       = sectionName
        self.webPublicationDate = publishedAt
        self.fields            = ArticleFields(
            bodyText:  saved.bodyText,
            thumbnail: saved.thumbnailURL,
            trailText: saved.trailText,
            byline:    saved.byline
        )
    }
}

extension SavedArticle {
    /// Populates a SavedArticle entity from an API Article.
    func populate(from article: Article) {
        apiId             = article.apiId
        title             = article.webTitle
        sectionName       = article.sectionName
        webURL            = article.webUrl
        thumbnailURL      = article.fields?.thumbnail
        trailText         = article.cleanTrailText
        byline            = article.displayByline
        bodyText          = article.fields?.bodyText
        publishedAt       = article.webPublicationDate
        estimatedReadTime = Int16(article.estimatedReadTime)
    }
}
