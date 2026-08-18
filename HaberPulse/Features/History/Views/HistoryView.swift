import SwiftUI

struct HistoryView: View {
    @StateObject private var vm = HistoryViewModel()

    var body: some View {
        NavigationStack {
            Group {
                if vm.readArticles.isEmpty {
                    EmptyStateView(
                        icon: "clock.arrow.circlepath",
                        title: NSLocalizedString("history_empty_title", comment: ""),
                        subtitle: NSLocalizedString("history_empty_subtitle", comment: "")
                    )
                } else {
                    articleList
                }
            }
            .navigationTitle(NSLocalizedString("tab_history", comment: ""))
            .toolbar {
                if !vm.readArticles.isEmpty {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(role: .destructive) {
                            vm.showClearAlert = true
                        } label: {
                            Label(
                                NSLocalizedString("history_clear", comment: ""),
                                systemImage: "trash"
                            )
                        }
                    }
                }
            }
            .alert(
                NSLocalizedString("history_clear_confirm_title", comment: ""),
                isPresented: $vm.showClearAlert
            ) {
                Button(NSLocalizedString("history_clear", comment: ""), role: .destructive) {
                    withAnimation { vm.clearHistory() }
                }
                Button(NSLocalizedString("cancel", comment: ""), role: .cancel) {}
            } message: {
                Text(NSLocalizedString("history_clear_confirm_message", comment: ""))
            }
        }
        .onAppear { vm.loadHistory() }
    }

    private var articleList: some View {
        List {
            ForEach(vm.readArticles) { article in
                NavigationLink(value: article) {
                    VStack(alignment: .leading, spacing: 2) {
                        ArticleRowView(article: article)
                        if let readDate = vm.readDate(for: article) {
                            Text(
                                String(format: NSLocalizedString("read_on", comment: ""), readDate.relativeFormatted)
                            )
                            .font(.caption2)
                            .foregroundStyle(.tertiary)
                            .padding(.leading, 102)
                        }
                    }
                }
                .buttonStyle(.plain)
            }
            .listRowBackground(Color(.secondarySystemGroupedBackground))
            .listRowSeparator(.hidden)
        }
        .listStyle(.insetGrouped)
        .navigationDestination(for: Article.self) { article in
            ArticleDetailView(article: article)
        }
    }
}

#Preview {
    HistoryView()
}
