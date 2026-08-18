// ArticleRowView.swift
// DataOriantedContentReader
// Features → Feed → Views

import SwiftUI

/// Daha kompakt, yatay düzende makale satırı (liste için).
struct ArticleRowView: View {
    let article: Article
    var isBookmarked: Bool = false
    var onBookmark: (() -> Void)? = nil

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Thumbnail
            AsyncImage(url: article.thumbnailURL) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                case .failure, .empty:
                    Rectangle()
                        .fill(Color(.tertiarySystemGroupedBackground))
                        .overlay {
                            Image(systemName: "newspaper")
                                .font(.title3)
                                .foregroundStyle(.secondary)
                        }
                @unknown default:
                    EmptyView()
                }
            }
            .frame(width: 90, height: 70)
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))

            // Text content
            VStack(alignment: .leading, spacing: 5) {
                HStack {
                    SectionBadge(name: article.sectionName)
                    Spacer()
                    Text(article.webPublicationDate.relativeFormatted)
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                }

                Text(article.webTitle)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.primary)
                    .lineLimit(2)

                HStack {
                    if !article.displayByline.isEmpty {
                        Text(article.displayByline)
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                    }
                    Spacer()
                    Label("\(article.estimatedReadTime) dk", systemImage: "clock")
                        .font(.caption2)
                        .foregroundStyle(.tertiary)

                    if let onBookmark {
                        Button(action: onBookmark) {
                            Image(systemName: isBookmarked ? "bookmark.fill" : "bookmark")
                                .font(.caption)
                                .foregroundStyle(isBookmarked ? Color.brandPrimary : .secondary)
                                .contentTransition(.symbolEffect(.replace))
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
        .padding(.vertical, 4)
    }
}
