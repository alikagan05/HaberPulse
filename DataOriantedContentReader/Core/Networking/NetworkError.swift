// NetworkError.swift
// DataOriantedContentReader
// Core → Networking

import Foundation

enum NetworkError: LocalizedError, Equatable {
    case invalidURL
    case requestFailed(statusCode: Int)
    case decodingFailed(String)
    case noInternet
    case timeout
    case unknown(String)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return NSLocalizedString("error_invalid_url", comment: "")
        case .requestFailed(let code):
            return String(format: NSLocalizedString("error_request_failed", comment: ""), code)
        case .decodingFailed(let detail):
            return "\(NSLocalizedString("error_decoding", comment: "")): \(detail)"
        case .noInternet:
            return NSLocalizedString("error_no_internet", comment: "")
        case .timeout:
            return NSLocalizedString("error_timeout", comment: "")
        case .unknown(let msg):
            return msg
        }
    }

    var recoverySuggestion: String? {
        switch self {
        case .noInternet:
            return NSLocalizedString("error_no_internet_recovery", comment: "")
        case .timeout:
            return NSLocalizedString("error_timeout_recovery", comment: "")
        case .requestFailed(let code) where code == 401:
            return NSLocalizedString("error_api_key_invalid", comment: "")
        default:
            return NSLocalizedString("error_generic_recovery", comment: "")
        }
    }

    // MARK: - Equatable
    static func == (lhs: NetworkError, rhs: NetworkError) -> Bool {
        lhs.errorDescription == rhs.errorDescription
    }
}
