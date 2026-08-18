// ErrorView.swift
// DataOriantedContentReader
// UIComponents

import SwiftUI

struct ErrorView: View {
    let error: NetworkError
    let retryAction: () async -> Void

    @State private var isRetrying = false

    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: iconName)
                .font(.system(size: 56, weight: .light))
                .foregroundStyle(iconColor)

            VStack(spacing: 8) {
                Text(error.errorDescription ?? NSLocalizedString("error_generic", comment: ""))
                    .font(.title3.weight(.semibold))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.primary)

                if let suggestion = error.recoverySuggestion {
                    Text(suggestion)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }
            }

            Button {
                isRetrying = true
                Task {
                    await retryAction()
                    isRetrying = false
                }
            } label: {
                Label(
                    isRetrying
                        ? NSLocalizedString("retrying", comment: "")
                        : NSLocalizedString("retry", comment: ""),
                    systemImage: "arrow.clockwise"
                )
                .font(.subheadline.weight(.medium))
                .padding(.horizontal, 28)
                .padding(.vertical, 12)
                .background(Color.brandPrimary)
                .foregroundStyle(.white)
                .clipShape(Capsule())
                .opacity(isRetrying ? 0.7 : 1)
            }
            .buttonStyle(.plain)
            .disabled(isRetrying)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGroupedBackground))
    }

    private var iconName: String {
        switch error {
        case .noInternet: return "wifi.slash"
        case .timeout:    return "clock.badge.xmark"
        case .requestFailed(let code) where code == 401: return "key.slash"
        default:          return "exclamationmark.triangle"
        }
    }

    private var iconColor: Color {
        switch error {
        case .noInternet: return .orange
        case .timeout:    return .yellow
        default:          return .red
        }
    }
}
