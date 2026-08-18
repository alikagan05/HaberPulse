// ArticleDetailView.swift
// DataOriantedContentReader
// Features → Detail → Views

import SwiftUI

struct ArticleDetailView: View {
    let article: Article
    @StateObject private var vm: DetailViewModel

    init(article: Article) {
        self.article = article
        _vm = StateObject(wrappedValue: DetailViewModel(article: article))
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                // Hero Image
                if let url = article.thumbnailURL {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(16/9, contentMode: .fill)
                        default:
                            Color(.tertiarySystemGroupedBackground)
                                .frame(height: 220)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 240)
                    .clipped()
                }

                VStack(alignment: .leading, spacing: 16) {
                    // Section + date
                    HStack {
                        SectionBadge(name: article.sectionName)
                        Spacer()
                        Text(article.webPublicationDate.longFormatted)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    // Title
                    Text(article.webTitle)
                        .font(.title2.weight(.bold))
                        .foregroundStyle(.primary)
                        .fixedSize(horizontal: false, vertical: true)

                    // Byline
                    if !article.displayByline.isEmpty {
                        HStack(spacing: 6) {
                            Image(systemName: "person.circle.fill")
                                .foregroundStyle(.secondary)
                            Text(article.displayByline)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }

                    // Read time
                    HStack(spacing: 6) {
                        Image(systemName: "clock")
                            .foregroundStyle(.secondary)
                        Text(String(format: NSLocalizedString("read_time_format", comment: ""), article.estimatedReadTime))
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }

                    Divider()

                    // Body text or trail text
                    let bodyText = article.fields?.bodyText?.strippingHTML() ?? article.cleanTrailText
                    if bodyText.isEmpty {
                        // No body text available — open in browser
                        VStack(spacing: 12) {
                            Text(NSLocalizedString("detail_no_body", comment: ""))
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.center)

                            if let url = URL(string: article.webUrl) {
                                Link(destination: url) {
                                    Label(
                                        NSLocalizedString("open_in_browser", comment: ""),
                                        systemImage: "safari"
                                    )
                                    .font(.subheadline.weight(.medium))
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 10)
                                    .background(Color.brandPrimary)
                                    .foregroundStyle(.white)
                                    .clipShape(Capsule())
                                }
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 20)
                    } else {
                        Text(bodyText)
                            .font(.body)
                            .foregroundStyle(.primary)
                            .lineSpacing(6)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    // Source link
                    if let url = URL(string: article.webUrl) {
                        Divider()
                        Link(destination: url) {
                            Label(
                                NSLocalizedString("view_original", comment: ""),
                                systemImage: "arrow.up.right.square"
                            )
                            .font(.caption)
                            .foregroundStyle(Color.brandPrimary)
                        }
                    }
                }
                .padding(20)
            }
        }
        .background(Color(.systemGroupedBackground))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                // Bookmark
                Button {
                    vm.toggleBookmark()
                } label: {
                    Image(systemName: vm.isBookmarked ? "bookmark.fill" : "bookmark")
                        .foregroundStyle(vm.isBookmarked ? Color.brandPrimary : .primary)
                        .contentTransition(.symbolEffect(.replace))
                }

                // Share
                ShareLink(
                    item: URL(string: article.webUrl) ?? URL(string: "https://theguardian.com")!,
                    subject: Text(article.webTitle),
                    message: Text(article.cleanTrailText)
                )
            }
        }
        .onAppear {
            vm.onAppear()
        }
    }
}
