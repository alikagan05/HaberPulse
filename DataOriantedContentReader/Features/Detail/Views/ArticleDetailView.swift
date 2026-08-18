import SwiftUI
#if canImport(Translation)
import Translation
#endif

struct ArticleDetailView: View {
    let article: Article
    @StateObject private var vm: DetailViewModel

    #if canImport(Translation)
    @State private var translationConfig: TranslationSession.Configuration?
    #endif

    @State private var isTranslating = false

    init(article: Article) {
        self.article = article
        _vm = StateObject(wrappedValue: DetailViewModel(article: article))
    }

    var displayedTitle: String {
        if vm.isShowingTranslation, let translated = vm.translatedTitle, !translated.isEmpty {
            return translated
        }
        return article.webTitle
    }

    var originalBodyText: String {
        article.fields?.bodyText?.strippingHTML() ?? article.cleanTrailText
    }

    var displayedBodyText: String {
        if vm.isShowingTranslation, let translated = vm.translatedBody, !translated.isEmpty {
            return translated
        }
        return originalBodyText
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
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
                    HStack {
                        Text(article.sourceName)
                            .font(.caption2.weight(.bold))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.brandPrimary.opacity(0.12))
                            .foregroundStyle(Color.brandPrimary)
                            .clipShape(Capsule())

                        SectionBadge(name: article.sectionName)

                        Spacer()

                        Text(article.webPublicationDate.longFormatted)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    if !article.isTurkish {
                        translationBanner
                    }

                    Text(displayedTitle)
                        .font(.title2.weight(.bold))
                        .foregroundStyle(.primary)
                        .fixedSize(horizontal: false, vertical: true)
                        .animation(.easeInOut(duration: 0.25), value: vm.isShowingTranslation)

                    if !article.displayByline.isEmpty {
                        HStack(spacing: 6) {
                            Image(systemName: "person.circle.fill")
                                .foregroundStyle(.secondary)
                            Text(article.displayByline)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }

                    HStack(spacing: 6) {
                        Image(systemName: "clock")
                            .foregroundStyle(.secondary)
                        Text(String(format: NSLocalizedString("read_time_format", comment: ""), article.estimatedReadTime))
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }

                    Divider()

                    if displayedBodyText.isEmpty {
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
                        Text(displayedBodyText)
                            .font(.body)
                            .foregroundStyle(.primary)
                            .lineSpacing(6)
                            .fixedSize(horizontal: false, vertical: true)
                            .animation(.easeInOut(duration: 0.25), value: vm.isShowingTranslation)
                    }

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
                Button {
                    vm.toggleBookmark()
                } label: {
                    Image(systemName: vm.isBookmarked ? "bookmark.fill" : "bookmark")
                        .foregroundStyle(vm.isBookmarked ? Color.brandPrimary : .primary)
                        .contentTransition(.symbolEffect(.replace))
                }

                ShareLink(
                    item: URL(string: article.webUrl) ?? URL(string: "https://theguardian.com")!,
                    subject: Text(displayedTitle),
                    message: Text(displayedBodyText)
                )
            }
        }
        #if canImport(Translation)
        .translationTask(translationConfig) { session in
            do {
                isTranslating = true
                let titleResp = try await session.translate(article.webTitle)
                var bodyRespText: String? = nil

                if !originalBodyText.isEmpty {
                    let bodyResp = try await session.translate(originalBodyText)
                    bodyRespText = bodyResp.targetText
                }

                vm.applyTranslation(title: titleResp.targetText, body: bodyRespText)
                isTranslating = false
            } catch {
                isTranslating = false
            }
        }
        #endif
        .onAppear {
            vm.onAppear()
        }
    }

    private var translationBanner: some View {
        HStack {
            Image(systemName: "translate")
                .font(.subheadline)
                .foregroundStyle(Color.brandPrimary)

            if vm.isShowingTranslation {
                Text(NSLocalizedString("translation_active_tr", comment: ""))
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.primary)
                Spacer()
                Button {
                    withAnimation { vm.toggleTranslationView() }
                } label: {
                    Text(NSLocalizedString("show_original", comment: ""))
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Color.brandPrimary)
                }
            } else if vm.translatedTitle != nil {
                Text(NSLocalizedString("translation_available", comment: ""))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer()
                Button {
                    withAnimation { vm.toggleTranslationView() }
                } label: {
                    Text(NSLocalizedString("translate_to_tr", comment: ""))
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Color.brandPrimary)
                }
            } else {
                Text(NSLocalizedString("article_in_english", comment: ""))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer()
                Button {
                    triggerTranslation()
                } label: {
                    HStack(spacing: 4) {
                        if isTranslating {
                            ProgressView()
                                .scaleEffect(0.8)
                        }
                        Text(NSLocalizedString("translate_to_tr", comment: ""))
                            .font(.caption.weight(.semibold))
                    }
                    .foregroundStyle(Color.brandPrimary)
                }
                .disabled(isTranslating)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    private func triggerTranslation() {
        #if canImport(Translation)
        if #available(iOS 17.4, *) {
            if translationConfig == nil {
                translationConfig = .init(source: .init(identifier: "en"), target: .init(identifier: "tr"))
            } else {
                translationConfig?.invalidate()
            }
        }
        #endif
    }
}
