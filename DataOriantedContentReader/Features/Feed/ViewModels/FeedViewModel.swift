// FeedViewModel.swift
// DataOriantedContentReader
// Features → Feed → ViewModels

import Foundation
import Combine

@MainActor
final class FeedViewModel: ObservableObject {

    // MARK: - Published State
    @Published var articles: [Article] = []
    @Published var isLoading = false
    @Published var isLoadingMore = false
    @Published var error: NetworkError?
    @Published var selectedSection = ""
    @Published var fromDate: Date? = nil
    @Published var toDate: Date? = nil
    @Published var showFilterSheet = false

    // MARK: - Pagination
    private var currentPage = 1
    private var totalPages  = 1
    var canLoadMore: Bool { currentPage < totalPages && !isLoadingMore }

    // MARK: - Dependencies
    private let apiClient: APIClient
    private let persistence: PersistenceController

    // MARK: - Init
    // AppEnvironment.shared'a doğrudan erişim: ViewModel @MainActor,
    // AppEnvironment nonisolated(unsafe) — erişim güvenli.
    init() {
        self.apiClient   = AppEnvironment.shared.apiClient
        self.persistence = AppEnvironment.shared.persistence
    }

    // MARK: - Public Methods

    func loadFeed() async {
        guard !isLoading else { return }
        isLoading    = true
        error        = nil
        currentPage  = 1

        defer { isLoading = false }

        guard let url = Endpoints.feed(
            section: selectedSection,
            page: 1,
            fromDate: fromDate?.apiFormatted,
            toDate: toDate?.apiFormatted
        ) else {
            error = .invalidURL
            return
        }

        do {
            let response: GuardianResponse = try await apiClient.fetch(url)
            articles   = response.response.results
            totalPages = response.response.pages
            AppLogger.viewModel.info("Feed loaded: \(self.articles.count) articles, \(self.totalPages) pages")
        } catch let netError as NetworkError {
            error = netError
        } catch {
            self.error = .unknown(error.localizedDescription)
        }
    }

    func loadMore() async {
        guard canLoadMore, !isLoadingMore else { return }
        isLoadingMore = true
        defer { isLoadingMore = false }

        let nextPage = currentPage + 1
        guard let url = Endpoints.feed(
            section: selectedSection,
            page: nextPage,
            fromDate: fromDate?.apiFormatted,
            toDate: toDate?.apiFormatted
        ) else { return }

        do {
            let response: GuardianResponse = try await apiClient.fetch(url)
            articles += response.response.results
            currentPage = nextPage
        } catch let netError as NetworkError {
            error = netError
        } catch {
            self.error = .unknown(error.localizedDescription)
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
}
