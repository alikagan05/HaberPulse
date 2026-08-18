import Foundation

final class AppEnvironment {
    static let shared = AppEnvironment()

    let apiClient: APIClient
    let persistence: PersistenceController

    init(
        apiClient: APIClient = .shared,
        persistence: PersistenceController = .shared
    ) {
        self.apiClient   = apiClient
        self.persistence = persistence
    }
}
