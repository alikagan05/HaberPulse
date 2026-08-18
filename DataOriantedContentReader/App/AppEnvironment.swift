// AppEnvironment.swift
// DataOriantedContentReader
// App

import Foundation

/// Dependency Injection container.
final class AppEnvironment {

    // MARK: - Singleton
    static let shared = AppEnvironment()

    // MARK: - Dependencies
    let apiClient: APIClient
    let persistence: PersistenceController

    // MARK: - Init
    init(
        apiClient: APIClient = .shared,
        persistence: PersistenceController = .shared
    ) {
        self.apiClient   = apiClient
        self.persistence = persistence
    }
}
