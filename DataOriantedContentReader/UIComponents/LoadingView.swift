// LoadingView.swift
// DataOriantedContentReader
// UIComponents

import SwiftUI

struct LoadingView: View {
    var message: String = NSLocalizedString("loading", comment: "")

    var body: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.4)
                .tint(.brandPrimary)
            Text(message)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGroupedBackground))
    }
}

/// Listenin alt kısmında gösterilen "daha fazla yükleniyor" göstergesi.
struct LoadMoreIndicator: View {
    var body: some View {
        HStack(spacing: 10) {
            ProgressView()
                .tint(.secondary)
            Text(NSLocalizedString("loading_more", comment: ""))
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
    }
}

#Preview {
    LoadingView()
}
