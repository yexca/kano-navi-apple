import KanoNaviCore
import SwiftUI

/// The timeline's videos by Japan month, or why there are none, and the row
/// that reads the next page, for a scroll target lazy stack. The first
/// section has no header, since the navigation subtitle names the section at
/// the top; each later one opens with its name, which scrolls with the
/// videos. Each item spans the width less the standard margins and is
/// identified by its `VideoTimelineSlot`.
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
                            .id(VideoTimelineSlot(sectionID: section.id, cardID: card.id))
                    }
                } header: {
                    if section.id != sections.first?.id {
                        header(for: section)
                    }
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

    /// A section's name, set apart from the videos before it.
    private func header(for section: VideoTimelineSection) -> some View {
        section.title(locale: locale)
            .font(.title3.bold())
            .accessibilityAddTraits(.isHeader)
            .padding(.horizontal)
            .padding(.top, 24)
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
