// AppEnvironment.swift
// DataOriantedContentReader
// App

import Foundation

/// Dependency Injection container.
/// @MainActor kaldırıldı — nonisolated(unsafe) static let ile her context'ten erişilebilir.
/// ObservableObject kaldırıldı — ViewModels .shared'a doğrudan erişiyor.
final class AppEnvironment {

    // MARK: - Singleton
    // nonisolated(unsafe): SWIFT_DEFAULT_ACTOR_ISOLATION=MainActor'ü bypass eder.
    nonisolated(unsafe) static let shared = AppEnvironment()

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
