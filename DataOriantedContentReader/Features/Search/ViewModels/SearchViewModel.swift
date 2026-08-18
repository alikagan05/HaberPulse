import Foundation
import Combine
import OSLog

@MainActor
final class SearchViewModel: ObservableObject {
    @Published var query: String = ""
    @Published var selectedSection: String = ""
    @Published var results: [Article] = []
    @Published var isLoading: Bool = false
    @Published var error: NetworkError? = nil

    private var currentPage: Int = 1
    private var totalPages: Int = 1
    private var searchTask: Task<Void, Never>?

    private let apiClient: APIClient
    private let persistence: PersistenceController

    init() {
        self.apiClient   = AppEnvironment.shared.apiClient
        self.persistence = AppEnvironment.shared.persistence
    }

    func onQueryChanged() {
        searchTask?.cancel()
        guard !query.isBlank else {
            results = []
            return
        }
        searchTask = Task {
            try? await Task.sleep(nanoseconds: 400_000_000)
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
            AppLogger.viewModel.info("Search '\(self.query)': \(self.results.count) results")
        } catch let netError as NetworkError {
            error = netError
        } catch {
            self.error = .unknown(error.localizedDescription)
        }
    }

    func loadMore() async {
        guard currentPage < totalPages, !isLoading else { return }
        let nextPage = currentPage + 1
        guard let url = Endpoints.search(
            query: query,
            section: selectedSection,
            page: nextPage
        ) else { return }

        do {
            let response: GuardianResponse = try await apiClient.fetch(url)
            results += response.response.results
            currentPage = nextPage
        } catch {
            AppLogger.viewModel.error("Search loadMore failed: \(error.localizedDescription)")
        }
    }

    func toggleBookmark(article: Article) {
        persistence.toggleBookmark(for: article)
    }

    func isBookmarked(_ article: Article) -> Bool {
        persistence.isBookmarked(apiId: article.apiId)
    }
}
