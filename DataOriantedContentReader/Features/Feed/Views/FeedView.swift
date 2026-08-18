import SwiftUI

struct FeedView: View {
    @StateObject private var vm = FeedViewModel()
    @ObservedObject private var langManager = LanguageManager.shared
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                sourceSelectorBar

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
            }
            .navigationTitle(NSLocalizedString("tab_feed", comment: ""))
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        withAnimation {
                            langManager.toggleLanguage()
                        }
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "globe")
                            Text(langManager.currentLanguage.shortLabel)
                                .font(.caption.weight(.bold))
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.brandPrimary.opacity(0.15))
                        .foregroundStyle(Color.brandPrimary)
                        .clipShape(Capsule())
                    }
                }

                if vm.selectedSource.id == "guardian" {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        filterButton
                    }
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
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .active {
                Task {
                    await vm.refreshIfStale()
                }
            }
        }
    }

    private var sourceSelectorBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(vm.sources) { source in
                    let isSelected = vm.selectedSourceId == source.id
                    Button {
                        vm.selectSource(source.id)
                    } label: {
                        HStack(spacing: 5) {
                            Image(systemName: source.iconName)
                                .font(.caption2)
                            Text(source.id == "all" ? NSLocalizedString(source.name, comment: "") : source.name)
                                .font(Font.caption.weight(isSelected ? .semibold : .regular))
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 7)
                        .background(
                            isSelected
                                ? Color.brandPrimary
                                : Color(.secondarySystemGroupedBackground)
                        )
                        .foregroundStyle(isSelected ? Color.white : Color.primary)
                        .clipShape(Capsule())
                        .shadow(color: Color.black.opacity(0.04), radius: 3, x: 0, y: 1)
                    }
                    .buttonStyle(.plain)
                    .animation(.easeInOut(duration: 0.2), value: vm.selectedSourceId)
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
        }
        .background(Color(.systemGroupedBackground))
    }

    private var articleList: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                if !vm.selectedSection.isEmpty && vm.selectedSource.id == "guardian" {
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
