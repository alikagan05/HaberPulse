import SwiftUI

struct SearchView: View {
    @StateObject private var vm = SearchViewModel()

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                sectionChips

                Group {
                    if vm.isLoading && vm.results.isEmpty {
                        LoadingView()
                    } else if let error = vm.error, vm.results.isEmpty {
                        ErrorView(error: error) {
                            await vm.search()
                        }
                    } else if vm.query.isBlank {
                        searchPrompt
                    } else if vm.results.isEmpty {
                        EmptyStateView(
                            icon: "magnifyingglass",
                            title: NSLocalizedString("search_no_results_title", comment: ""),
                            subtitle: NSLocalizedString("search_no_results_subtitle", comment: "")
                        )
                    } else {
                        resultsList
                    }
                }
            }
            .navigationTitle(NSLocalizedString("tab_search", comment: ""))
            .searchable(
                text: $vm.query,
                prompt: NSLocalizedString("search_placeholder", comment: "")
            )
            .onChange(of: vm.query) { _, _ in
                vm.onQueryChanged()
            }
        }
    }

    private var sectionChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(Endpoints.sections, id: \.id) { section in
                    Button {
                        vm.selectedSection = section.id
                        if !vm.query.isBlank {
                            Task { await vm.search() }
                        }
                    } label: {
                        Text(NSLocalizedString(section.label, comment: ""))
                            .font(Font.caption.weight(vm.selectedSection == section.id ? .semibold : .regular))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(
                                vm.selectedSection == section.id
                                    ? Color.brandPrimary
                                    : Color(.tertiarySystemGroupedBackground)
                            )
                            .foregroundStyle(vm.selectedSection == section.id ? .white : .primary)
                            .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                    .animation(.easeInOut(duration: 0.2), value: vm.selectedSection)
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 10)
        }
        .background(Color(.systemGroupedBackground))
    }

    private var resultsList: some View {
        List {
            ForEach(vm.results) { article in
                NavigationLink(value: article) {
                    ArticleRowView(
                        article: article,
                        isBookmarked: vm.isBookmarked(article),
                        onBookmark: { vm.toggleBookmark(article: article) }
                    )
                }
                .buttonStyle(.plain)
                .onAppear {
                    if article.id == vm.results.suffix(3).first?.id {
                        Task { await vm.loadMore() }
                    }
                }
            }
            .listRowBackground(Color(.secondarySystemGroupedBackground))
            .listRowSeparator(.hidden)

            if vm.isLoading {
                LoadMoreIndicator()
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
            }
        }
        .listStyle(.insetGrouped)
        .navigationDestination(for: Article.self) { article in
            ArticleDetailView(article: article)
        }
    }

    private var searchPrompt: some View {
        VStack(spacing: 20) {
            Image(systemName: "doc.text.magnifyingglass")
                .font(.system(size: 56, weight: .light))
                .foregroundStyle(.secondary)
            Text(NSLocalizedString("search_prompt", comment: ""))
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGroupedBackground))
    }
}

#Preview {
    SearchView()
}
