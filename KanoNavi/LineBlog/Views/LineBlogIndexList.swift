import KanoNaviCore
import SwiftUI

/// The list of the archive's articles under their months.
struct LineBlogIndexList: View {
    let index: LineBlogIndexResponse
    let listing: LineBlogIndexListing
    let notice: DocumentNotice?
    let reload: () async -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var isShowingInfo = false

    var body: some View {
        ScrollViewReader { proxy in
            List {
                if let notice {
                    Section {
                        DocumentStatusNotice(notice: notice, reload: reload)
                    }
                }

                ForEach(listing.months) { month in
                    Section {
                        ForEach(month.posts) { post in
                            NavigationLink(value: LineBlogDestination.article(id: post.id)) {
                                LineBlogIndexRow(post: post)
                            }
                        }
                    } header: {
                        LineBlogMonthHeader(month: month)
                    }
                }
            }
            .listStyle(.insetGrouped)
            .refreshable {
                await reload()
            }
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    LineBlogMonthMenu(years: listing.years) { month in
                        jump(to: month, with: proxy)
                    }
                }
                ToolbarItem(placement: .primaryAction) {
                    Button(.LineBlog.info, systemImage: "info.circle") {
                        isShowingInfo = true
                    }
                    .accessibilityIdentifier("lineblog.info")
                }
            }
            .sheet(isPresented: $isShowingInfo) {
                LineBlogInfoSheet(originalBlogURL: index.originalBlogURL)
            }
        }
    }

    /// Scrolls the month's first article to the top of the list.
    private func jump(to month: LineBlogIndexListing.Month, with proxy: ScrollViewProxy) {
        guard let first = month.posts.first else { return }
        if reduceMotion {
            proxy.scrollTo(first.id, anchor: .top)
        } else {
            withAnimation {
                proxy.scrollTo(first.id, anchor: .top)
            }
        }
    }
}
