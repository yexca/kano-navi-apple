import KanoNaviCore
import SwiftUI

/// The timeline's posts by Japan month, each in its own card, or why there
/// are none, and the row that reads the next page, for a scroll target lazy
/// stack. The first month has no header, since the navigation subtitle
/// names the month at the top; each later one opens with its name, which
/// scrolls with the posts. Each card is identified by its `TimelineSlot`.
struct PostTimelineItems: View {
    let model: PostTimelineModel

    @Environment(\.locale) private var locale

    var body: some View {
        if let listing = model.listing {
            let sections = model.sections
            ForEach(sections) { section in
                Section {
                    ForEach(section.cards) { card in
                        PostTimelineCard(card: card)
                            .id(TimelineSlot(sectionID: section.id, itemID: card.id))
                    }
                } header: {
                    if section.id != sections.first?.id {
                        header(for: section)
                    }
                }
            }
            if listing.items.isEmpty {
                note(model.account == nil ? .Posts.timelineEmpty : .Posts.accountEmpty)
            }
            if listing.hasNext {
                ArchiveMoreRow(
                    itemCount: listing.items.count, isLoading: model.isLoadingMore,
                    failed: model.moreFailure != nil, loadMore: model.loadMore
                )
                .padding()
            }
        } else if model.notice == nil {
            HStack(spacing: 8) {
                ProgressView()
                Text(.Archive.loading)
                    .foregroundStyle(.secondary)
            }
            .padding()
        }
    }

    /// A month's name, set apart from the posts before it.
    private func header(for section: PostTimelineSection) -> some View {
        Text(verbatim: section.month.first.monthTitle(locale: locale))
            .font(.title3.bold())
            .accessibilityAddTraits(.isHeader)
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, 4)
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func note(_ text: LocalizedStringResource) -> some View {
        Text(text)
            .foregroundStyle(.secondary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
    }
}
