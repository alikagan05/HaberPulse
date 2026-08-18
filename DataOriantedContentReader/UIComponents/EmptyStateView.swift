// EmptyStateView.swift
// DataOriantedContentReader
// UIComponents

import SwiftUI

struct EmptyStateView: View {
    let icon: String
    let title: String
    let subtitle: String
    var action: (() -> Void)? = nil
    var actionTitle: String = ""

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: icon)
                .font(.system(size: 56, weight: .light))
                .foregroundStyle(.secondary)
                .symbolEffect(.pulse, isActive: true)

            VStack(spacing: 6) {
                Text(title)
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(.primary)
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }

            if let action, !actionTitle.isEmpty {
                Button(action: action) {
                    Text(actionTitle)
                        .font(.subheadline.weight(.medium))
                        .padding(.horizontal, 24)
                        .padding(.vertical, 10)
                        .background(Color.brandPrimary)
                        .foregroundStyle(.white)
                        .clipShape(Capsule())
                }
                .buttonStyle(.plain)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGroupedBackground))
    }
}

#Preview {
    EmptyStateView(
        icon: "newspaper",
        title: "Makale Bulunamadı",
        subtitle: "Farklı bir arama terimi veya filtre deneyebilirsin.",
        action: {},
        actionTitle: "Filtreleri Temizle"
    )
}
