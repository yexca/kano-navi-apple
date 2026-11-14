import KanoNaviCore
import SwiftUI

/// The timeline's videos under their Japan months, or why there are none,
/// and the row that reads the next page, for a lazy stack that pins its
/// section headers. Each item spans the width less the standard margins.
struct VideoTimelineItems: View {
    let model: VideoTimelineModel

    @Environment(\.locale) private var locale

    var body: some View {
        if let listing = model.listing {
            let sections = model.sections
            ForEach(sections) { section in
                Section {
                    ForEach(section.cards) { card in
                        VideoTimelineItem(card: card)
                            // About 16 points between items, as a feed.
                            .padding(.horizontal)
                            .padding(.vertical, 8)
                    }
                } header: {
                    header(for: section)
                }
            }
            if listing.items.isEmpty {
                note(.Videos.timelineEmpty)
            } else if sections.isEmpty, listing.hasNext == false {
                note(.Videos.filterEmpty)
            }
            if listing.hasNext {
                // Counts every loaded video, so a page the filter hides still
                // reads the next one while the row is on screen.
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

    /// A section's title across the width on the screen's background, so the
    /// covers scrolling under it while it is pinned stay hidden.
    private func header(for section: VideoTimelineSection) -> some View {
        Group {
            if section.isOnAir {
                Text(.Videos.onAir)
            } else if let month = section.month {
                Text(verbatim: month.title(locale: locale))
            }
        }
        .font(.headline)
        .accessibilityAddTraits(.isHeader)
        .padding(.horizontal)
        .padding(.vertical, 8)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.background)
    }

    private func note(_ text: LocalizedStringResource) -> some View {
        Text(text)
            .foregroundStyle(.secondary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
    }
}
