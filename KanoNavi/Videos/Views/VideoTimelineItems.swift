import KanoNaviCore
import SwiftUI

/// The timeline's videos under their Japan months, or why there are none,
/// and the row that reads the next page.
struct VideoTimelineItems: View {
    let model: VideoTimelineModel

    @Environment(\.locale) private var locale

    var body: some View {
        if let listing = model.listing {
            let sections = model.sections
            ForEach(sections) { section in
                Section {
                    ForEach(section.cards) { card in
                        VideoRow(card: card)
                    }
                } header: {
                    if section.isOnAir {
                        Text(.Videos.onAir)
                    } else if let month = section.month {
                        Text(verbatim: month.title(locale: locale))
                    }
                }
            }
            if listing.items.isEmpty {
                Section {
                    Text(.Videos.timelineEmpty)
                        .foregroundStyle(.secondary)
                }
            } else if sections.isEmpty, listing.hasNext == false {
                Section {
                    Text(.Videos.filterEmpty)
                        .foregroundStyle(.secondary)
                }
            }
            if listing.hasNext {
                Section {
                    // Counts every loaded video, so a page the filter hides
                    // still reads the next one while the row is on screen.
                    ArchiveMoreRow(
                        itemCount: listing.items.count, isLoading: model.isLoadingMore,
                        failed: model.moreFailure != nil, loadMore: model.loadMore)
                }
            }
        } else if model.notice == nil {
            Section {
                HStack(spacing: 8) {
                    ProgressView()
                    Text(.Archive.loading)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
}
