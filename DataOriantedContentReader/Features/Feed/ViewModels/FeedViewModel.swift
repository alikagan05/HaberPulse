import Foundation
import Combine
import OSLog

@MainActor
final class FeedViewModel: ObservableObject {
    @Published var articles: [Article] = []
    @Published var isLoading = false
    @Published var isLoadingMore = false
    @Published var error: NetworkError?
    @Published var selectedSection = ""
    @Published var selectedSourceId: String = "all"
    @Published var fromDate: Date? = nil
    @Published var toDate: Date? = nil
    @Published var showFilterSheet = false

    let sources = Endpoints.sources

    var selectedSource: NewsSource {
        sources.first(where: { $0.id == selectedSourceId }) ?? sources[0]
    }

    private var currentPage = 1
    private var totalPages  = 1
    var canLoadMore: Bool {
        selectedSource.id == "guardian" && currentPage < totalPages && !isLoadingMore
    }

    private let apiClient: APIClient
    private let rssClient: RSSClient
    private let persistence: PersistenceController

    private(set) var lastFetchDate: Date? = nil

    init() {
        self.apiClient   = AppEnvironment.shared.apiClient
        self.rssClient   = RSSClient.shared
        self.persistence = AppEnvironment.shared.persistence
    }

    func loadFeed() async {
        guard !isLoading else { return }
        isLoading    = true
        error        = nil
        currentPage  = 1

        defer { isLoading = false }

        do {
            if selectedSource.id == "all" {
                articles = try await loadAllSources()
            } else if selectedSource.id == "guardian" {
                articles = try await loadGuardianFeed(page: 1)
            } else if let feedURL = selectedSource.feedURL {
                articles = try await rssClient.fetchRSS(
                    from: feedURL,
                    sourceName: selectedSource.name,
                    sectionName: selectedSource.defaultSection
                )
            }
            lastFetchDate = Date()
            AppLogger.viewModel.info("Feed loaded: \(self.articles.count) articles at \(Date())")
        } catch let netError as NetworkError {
            error = netError
        } catch {
            self.error = .unknown(error.localizedDescription)
        }
    }

    func refreshIfStale(maxAgeSeconds: TimeInterval = 300) async {
        guard let last = lastFetchDate else {
            await loadFeed()
            return
        }
        if Date().timeIntervalSince(last) > maxAgeSeconds {
            await loadFeed()
        }
    }

    func loadMore() async {
        guard canLoadMore, !isLoadingMore else { return }
        isLoadingMore = true
        defer { isLoadingMore = false }

        let nextPage = currentPage + 1
        do {
            let nextArticles = try await loadGuardianFeed(page: nextPage)
            articles += nextArticles
            currentPage = nextPage
        } catch let netError as NetworkError {
            error = netError
        } catch {
            self.error = .unknown(error.localizedDescription)
        }
    }

    func selectSource(_ sourceId: String) {
        selectedSourceId = sourceId
        Task {
            await loadFeed()
        }
    }

    func resetFilters() {
        selectedSection = ""
        fromDate        = nil
        toDate          = nil
    }

    func recordRead(article: Article) {
        persistence.markAsRead(article: article)
    }

    func toggleBookmark(article: Article) {
        persistence.toggleBookmark(for: article)
    }

    func isBookmarked(_ article: Article) -> Bool {
        persistence.isBookmarked(apiId: article.apiId)
    }

    private func loadGuardianFeed(page: Int) async throws -> [Article] {
        guard let url = Endpoints.feed(
            section: selectedSection,
            page: page,
            fromDate: fromDate?.apiFormatted,
            toDate: toDate?.apiFormatted
        ) else {
            throw NetworkError.invalidURL
        }

        let response: GuardianResponse = try await apiClient.fetch(url)
        totalPages = response.response.pages
        return response.response.results
    }

    private func loadAllSources() async throws -> [Article] {
        var aggregated: [Article] = []

        await withTaskGroup(of: [Article].self) { group in
            group.addTask {
                (try? await self.loadGuardianFeed(page: 1)) ?? []
            }

            if let trtURL = URL(string: "https://www.trthaber.com/gundem_articles.rss") {
                group.addTask {
                    (try? await self.rssClient.fetchRSS(from: trtURL, sourceName: "TRT Haber", sectionName: "Gündem")) ?? []
                }
            }

            if let bbcURL = URL(string: "https://feeds.bbci.co.uk/turkce/rss.xml") {
                group.addTask {
                    (try? await self.rssClient.fetchRSS(from: bbcURL, sourceName: "BBC Türkçe", sectionName: "Dünya")) ?? []
                }
            }

            if let webteknoURL = URL(string: "https://www.webtekno.com/rss.xml") {
                group.addTask {
                    (try? await self.rssClient.fetchRSS(from: webteknoURL, sourceName: "Webtekno", sectionName: "Teknoloji")) ?? []
                }
            }

            for await result in group {
                aggregated.append(contentsOf: result)
            }
        }

        aggregated.sort { $0.webPublicationDate > $1.webPublicationDate }
        return aggregated
    }
}
