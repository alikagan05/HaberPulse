// APIClientTests.swift
// DataOriantedContentReaderTests

import XCTest
@testable import DataOriantedContentReader

final class APIClientTests: XCTestCase {

    // MARK: - Mock URLSession

    /// Mock URLSession'ı simüle eden yapı.
    private func makeMockSession(data: Data, statusCode: Int) -> URLSession {
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = []
        return URLSession(configuration: config)
    }

    // MARK: - Endpoints Tests

    func test_endpoints_feedURL_isValid() {
        let url = Endpoints.feed(section: "technology", page: 1)
        XCTAssertNotNil(url, "Feed URL should not be nil")
        XCTAssertTrue(url?.absoluteString.contains("section=technology") == true)
        XCTAssertTrue(url?.absoluteString.contains("page=1") == true)
        XCTAssertTrue(url?.absoluteString.contains("api-key=") == true)
    }

    func test_endpoints_searchURL_containsQuery() {
        let url = Endpoints.search(query: "swift programming", section: "", page: 1)
        XCTAssertNotNil(url)
        XCTAssertTrue(url?.absoluteString.contains("q=swift") == true)
    }

    func test_endpoints_feedURL_withDateRange() {
        let url = Endpoints.feed(
            section: "",
            page: 1,
            fromDate: "2025-01-01",
            toDate: "2025-01-31"
        )
        XCTAssertNotNil(url)
        XCTAssertTrue(url?.absoluteString.contains("from-date=2025-01-01") == true)
        XCTAssertTrue(url?.absoluteString.contains("to-date=2025-01-31") == true)
    }

    func test_endpoints_emptySection_notIncluded() {
        let url = Endpoints.feed(section: "", page: 1)
        XCTAssertFalse(url?.absoluteString.contains("section=") == true)
    }

    // MARK: - NetworkError Tests

    func test_networkError_equatable() {
        XCTAssertEqual(NetworkError.noInternet, NetworkError.noInternet)
        XCTAssertEqual(NetworkError.timeout, NetworkError.timeout)
        XCTAssertEqual(NetworkError.invalidURL, NetworkError.invalidURL)
    }

    func test_networkError_errorDescriptions_nonNil() {
        let errors: [NetworkError] = [
            .invalidURL,
            .requestFailed(statusCode: 404),
            .decodingFailed("parse error"),
            .noInternet,
            .timeout,
            .unknown("test"),
        ]
        for error in errors {
            XCTAssertNotNil(error.errorDescription, "\(error) should have a description")
        }
    }
}
