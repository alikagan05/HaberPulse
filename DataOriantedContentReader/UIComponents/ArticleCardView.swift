// ArticleCardView.swift
// DataOriantedContentReader
// UIComponents

import SwiftUI

/// Thumbnail, başlık, section badge ve meta bilgilerini gösteren kart bileşeni.
struct ArticleCardView: View {
    let article: Article
    var isBookmarked: Bool = false
    var onBookmark: (() -> Void)? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Thumbnail
            if let url = article.thumbnailURL {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(16/9, contentMode: .fill)
                    case .failure, .empty:
                        placeholderImage
                    @unknown default:
                        placeholderImage
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 180)
                .clipped()
            }

            // Content
            VStack(alignment: .leading, spacing: 10) {
                // Section + Date
                HStack {
                    SectionBadge(name: article.sectionName)
                    Spacer()
                    Text(article.webPublicationDate.relativeFormatted)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                // Title
                Text(article.webTitle)
                    .font(.headline)
                    .foregroundStyle(.primary)
                    .lineLimit(3)
                    .fixedSize(horizontal: false, vertical: true)

                // Trail text
                if !article.cleanTrailText.isEmpty {
                    Text(article.cleanTrailText)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }

                // Footer: byline + read time + bookmark
                HStack {
                    if !article.displayByline.isEmpty {
                        Text(article.displayByline)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                    }
                    Spacer()

                    // Read time
                    Label(
                        "\(article.estimatedReadTime) dk",
                        systemImage: "clock"
                    )
                    .font(.caption)
                    .foregroundStyle(.secondary)

                    // Bookmark button
                    if let onBookmark {
                        Button(action: onBookmark) {
                            Image(systemName: isBookmarked ? "bookmark.fill" : "bookmark")
                                .font(.subheadline)
                                .foregroundStyle(isBookmarked ? Color.brandPrimary : .secondary)
                                .contentTransition(.symbolEffect(.replace))
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding(14)
        }
        .cardStyle()
    }

    private var placeholderImage: some View {
        Rectangle()
            .fill(Color(.tertiarySystemGroupedBackground))
            .frame(maxWidth: .infinity)
            .frame(height: 180)
            .overlay {
                Image(systemName: "newspaper")
                    .font(.largeTitle)
                    .foregroundStyle(.secondary)
            }
    }
}

// MARK: - Section Badge

struct SectionBadge: View {
    let name: String

    var body: some View {
        Text(name.capitalized)
            .font(.caption2.weight(.semibold))
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Color.sectionColor(name).opacity(0.15))
            .foregroundStyle(Color.sectionColor(name))
            .clipShape(Capsule())
    }
}
