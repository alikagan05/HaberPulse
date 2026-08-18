import Foundation
import CoreData

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

struct Article: Identifiable, Decodable, Hashable {
    var id: String { apiId }
    let apiId: String
    let webTitle: String
    let webUrl: String
    let sectionName: String
    let webPublicationDate: Date
    let fields: ArticleFields?

    var sourceName: String = "The Guardian"
    var isTurkish: Bool = false
    var translatedTitle: String? = nil
    var translatedBody: String? = nil

    init(
        apiId: String,
        webTitle: String,
        webUrl: String,
        sectionName: String,
        webPublicationDate: Date,
        fields: ArticleFields?,
        sourceName: String = "The Guardian",
        isTurkish: Bool = false,
        translatedTitle: String? = nil,
        translatedBody: String? = nil
    ) {
        self.apiId              = apiId
        self.webTitle           = webTitle
        self.webUrl             = webUrl
        self.sectionName        = sectionName
        self.webPublicationDate = webPublicationDate
        self.fields             = fields
        self.sourceName         = sourceName
        self.isTurkish          = isTurkish
        self.translatedTitle    = translatedTitle
        self.translatedBody     = translatedBody
    }

    enum CodingKeys: String, CodingKey {
        case apiId = "id"
        case webTitle, webUrl, sectionName, webPublicationDate, fields
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.apiId              = try container.decode(String.self, forKey: .apiId)
        self.webTitle           = try container.decode(String.self, forKey: .webTitle)
        self.webUrl             = try container.decode(String.self, forKey: .webUrl)
        self.sectionName        = try container.decode(String.self, forKey: .sectionName)
        self.webPublicationDate = try container.decode(Date.self, forKey: .webPublicationDate)
        self.fields             = try container.decodeIfPresent(ArticleFields.self, forKey: .fields)
        self.sourceName         = "The Guardian"
        self.isTurkish          = false
        self.translatedTitle    = nil
        self.translatedBody     = nil
    }

    var estimatedReadTime: Int {
        let text = fields?.bodyText ?? fields?.trailText ?? ""
        return text.strippingHTML().estimatedReadTimeMinutes
    }

    var thumbnailURL: URL? {
        guard let str = fields?.thumbnail, !str.isEmpty else { return nil }
        return URL(string: str)
    }

    var cleanTrailText: String {
        fields?.trailText?.strippingHTML() ?? ""
    }

    var displayByline: String {
        guard let byline = fields?.byline, !byline.isBlank else { return sourceName }
        return byline
    }
}

struct ArticleFields: Decodable, Hashable {
    let bodyText: String?
    let thumbnail: String?
    let trailText: String?
    let byline: String?
}

extension Article {
    init?(from saved: SavedArticle) {
        guard let apiId = saved.apiId as String?,
              let webTitle = saved.title as String?,
              let webUrl = saved.webURL as String?,
              let sectionName = saved.sectionName as String?,
              let publishedAt = saved.publishedAt as Date?
        else { return nil }

        self.apiId              = apiId
        self.webTitle           = webTitle
        self.webUrl             = webUrl
        self.sectionName        = sectionName
        self.webPublicationDate = publishedAt
        self.sourceName         = saved.sourceName ?? "The Guardian"
        self.isTurkish          = saved.sourceName != "The Guardian"
        self.translatedTitle    = saved.translatedTitle
        self.translatedBody     = saved.translatedBody
        self.fields             = ArticleFields(
            bodyText:  saved.bodyText,
            thumbnail: saved.thumbnailURL,
            trailText: saved.trailText,
            byline:    saved.byline
        )
    }
}

extension SavedArticle {
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
        sourceName        = article.sourceName
        translatedTitle   = article.translatedTitle
        translatedBody    = article.translatedBody
    }
}
