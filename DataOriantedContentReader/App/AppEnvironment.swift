// AppEnvironment.swift
// DataOriantedContentReader
// App

import SwiftUI

/// Dependency Injection container — uygulamanın tüm paylaşılan bağımlılıklarını tutar.
/// `.environmentObject(AppEnvironment.shared)` ile view hiyerarşisine enjekte edilir.
@MainActor
final class AppEnvironment: ObservableObject {

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
