// FeedView.swift
// DataOriantedContentReader
// Features → Feed → Views

import SwiftUI

struct FeedView: View {
    @StateObject private var vm = FeedViewModel()

    var body: some View {
        NavigationStack {
            Group {
                if vm.isLoading && vm.articles.isEmpty {
                    LoadingView()
                } else if let error = vm.error, vm.articles.isEmpty {
                    ErrorView(error: error) {
                        await vm.loadFeed()
                    }
                } else if vm.articles.isEmpty {
                    EmptyStateView(
                        icon: "newspaper",
                        title: NSLocalizedString("feed_empty_title", comment: ""),
                        subtitle: NSLocalizedString("feed_empty_subtitle", comment: ""),
                        action: { vm.resetFilters(); Task { await vm.loadFeed() } },
                        actionTitle: NSLocalizedString("filter_reset", comment: "")
                    )
                } else {
                    articleList
                }
            }
            .navigationTitle(NSLocalizedString("tab_feed", comment: ""))
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    filterButton
                }
            }
            .sheet(isPresented: $vm.showFilterSheet) {
                FilterSheetView(
                    selectedSection: $vm.selectedSection,
                    fromDate: $vm.fromDate,
                    toDate: $vm.toDate
                ) {
                    await vm.loadFeed()
                }
            }
            .refreshable {
                await vm.loadFeed()
            }
        }
        .task {
            await vm.loadFeed()
        }
    }

    // MARK: - Article List
    private var articleList: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                // Section pill indicator
                if !vm.selectedSection.isEmpty {
                    activeSectionBanner
                }

                ForEach(vm.articles) { article in
                    NavigationLink(value: article) {
                        ArticleCardView(
                            article: article,
                            isBookmarked: vm.isBookmarked(article),
                            onBookmark: { vm.toggleBookmark(article: article) }
                        )
                        .padding(.horizontal)
                    }
                    .buttonStyle(.plain)
                    .onAppear {
                        // Sonsuz kaydırma: son 3 elemandan biri görününce yükle
                        if article.id == vm.articles.suffix(3).first?.id {
                            Task { await vm.loadMore() }
                        }
                    }
                }

                if vm.isLoadingMore {
                    LoadMoreIndicator()
                }

                if !vm.canLoadMore && !vm.articles.isEmpty {
                    Text(NSLocalizedString("all_loaded", comment: ""))
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                        .padding(.vertical, 16)
                }
            }
            .padding(.vertical, 12)
        }
        .navigationDestination(for: Article.self) { article in
            ArticleDetailView(article: article)
        }
        .background(Color(.systemGroupedBackground))
    }

    // MARK: - Active Section Banner
    private var activeSectionBanner: some View {
        HStack {
            SectionBadge(name: vm.selectedSection.isEmpty ? "all" : vm.selectedSection)
            Text(NSLocalizedString("filter_active", comment: ""))
                .font(.caption)
                .foregroundStyle(.secondary)
            Spacer()
            Button {
                vm.resetFilters()
                Task { await vm.loadFeed() }
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .foregroundStyle(.secondary)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .padding(.horizontal)
    }

    // MARK: - Filter Button
    private var filterButton: some View {
        Button {
            vm.showFilterSheet = true
        } label: {
            Image(systemName: hasActiveFilters ? "line.3.horizontal.decrease.circle.fill" : "line.3.horizontal.decrease.circle")
                .symbolEffect(.bounce, value: hasActiveFilters)
                .foregroundStyle(hasActiveFilters ? Color.brandPrimary : .primary)
        }
    }

    private var hasActiveFilters: Bool {
        !vm.selectedSection.isEmpty || vm.fromDate != nil || vm.toDate != nil
    }
}

#Preview {
    FeedView()
}
