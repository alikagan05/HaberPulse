// SearchViewModel.swift
// DataOriantedContentReader
// Features → Search → ViewModels

import Foundation
import Combine

@MainActor
final class SearchViewModel: ObservableObject {

    // MARK: - Published
    @Published var query        = ""
    @Published var results: [Article] = []
    @Published var isLoading    = false
    @Published var error: NetworkError?
    @Published var selectedSection = ""

    // MARK: - Pagination
    private var currentPage = 1
    private var totalPages  = 1
    var canLoadMore: Bool { currentPage < totalPages && !isLoading }

    // MARK: - Debounce
    private var searchTask: Task<Void, Never>?

    // MARK: - Dependencies
    private let apiClient: APIClient
    private let persistence: PersistenceController

    // MARK: - Init
    init(env: AppEnvironment = .shared) {
        self.apiClient   = env.apiClient
        self.persistence = env.persistence
    }

    // MARK: - Public Methods

    func onQueryChanged() {
        searchTask?.cancel()
        guard !query.isBlank else {
            results = []
            return
        }
        searchTask = Task {
            try? await Task.sleep(for: .milliseconds(400)) // debounce
            guard !Task.isCancelled else { return }
            await search()
        }
    }

    func search() async {
        guard !query.isBlank else { return }
        isLoading   = true
        error       = nil
        currentPage = 1
        defer { isLoading = false }

        guard let url = Endpoints.search(
            query: query,
            section: selectedSection,
            page: 1
        ) else {
            error = .invalidURL
            return
        }

        do {
            let response: GuardianResponse = try await apiClient.fetch(url)
            results    = response.response.results
            totalPages = response.response.pages
        } catch let netError as NetworkError {
            error = netError
        } catch {
            self.error = .unknown(error.localizedDescription)
        }
    }

    func loadMore() async {
        guard canLoadMore else { return }
        let nextPage = currentPage + 1
        guard let url = Endpoints.search(
            query: query,
            section: selectedSection,
            page: nextPage
        ) else { return }
        do {
            let response: GuardianResponse = try await apiClient.fetch(url)
            results    += response.response.results
            currentPage = nextPage
        } catch {}
    }

    func toggleBookmark(article: Article) {
        persistence.toggleBookmark(for: article)
    }

    func isBookmarked(_ article: Article) -> Bool {
        persistence.isBookmarked(apiId: article.apiId)
    }
}
