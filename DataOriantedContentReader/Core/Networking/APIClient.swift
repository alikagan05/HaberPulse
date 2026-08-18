// APIClient.swift
// DataOriantedContentReader
// Core → Networking

import Foundation
import OSLog   // ← açık import: SWIFT_UPCOMING_FEATURE_MEMBER_IMPORT_VISIBILITY için gerekli

/// Generic async/await network client. Thread-safe via `actor`.
actor APIClient {

    // MARK: - Singleton
    static let shared = APIClient()

    // MARK: - Private Properties
    private let session: URLSession
    private let decoder: JSONDecoder

    // MARK: - Init
    init(session: URLSession = .shared) {
        self.session = session
        self.decoder = JSONDecoder()
        self.decoder.dateDecodingStrategy = .iso8601
    }

    // MARK: - Public API

    /// Fetches and decodes any `Decodable` type from a given URL.
    func fetch<T: Decodable>(_ url: URL) async throws -> T {
        AppLogger.network.info("→ GET \(url.absoluteString)")

        let data: Data
        let response: URLResponse

        do {
            (data, response) = try await session.data(from: url)
        } catch let urlError as URLError {
            switch urlError.code {
            case .notConnectedToInternet, .networkConnectionLost:
                throw NetworkError.noInternet
            case .timedOut:
                throw NetworkError.timeout
            default:
                throw NetworkError.unknown(urlError.localizedDescription)
            }
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.unknown("Non-HTTP response")
        }

        AppLogger.network.info("← \(httpResponse.statusCode) \(url.lastPathComponent)")

        guard (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.requestFailed(statusCode: httpResponse.statusCode)
        }

        do {
            return try decoder.decode(T.self, from: data)
        } catch let decodingError {
            AppLogger.network.error("Decoding error: \(decodingError.localizedDescription)")
            throw NetworkError.decodingFailed(decodingError.localizedDescription)
        }
    }
}
