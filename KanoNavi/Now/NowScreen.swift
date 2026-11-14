import KanoNaviCore
import SwiftUI

/// The Now tab's screen for one set of services.
///
/// `RootView` starts and stops the dashboard store with the scene; this view
/// only reads it and refreshes it on demand. Coming Up reads the calendar
/// again whenever the dashboard is received (its `fetchedAt` changes, which
/// a new revision also causes) and on pull to refresh.
struct NowScreen: View {
    @State private var comingUp: NowComingUpModel
    /// The service's calendar feed, for the empty state's subscribe action;
    /// `nil` in previews without services.
    let feedURL: URL?

    @Environment(DashboardStore.self) private var dashboard

    init(calendar: CalendarReader?, feedURL: URL?) {
        // Reads the cached range at once, so Coming Up is on the first frame.
        // `NowView` builds this screen once, as its only input is the
        // services, which do not change.
        let model =
            calendar.map { NowComingUpModel(calendar: $0) }
            ?? NowComingUpModel(loader: { _ in throw APIError.offline })
        _comingUp = State(initialValue: model)
        self.feedURL = feedURL
    }

    var body: some View {
        NavigationStack {
            content
                .navigationTitle(.tabNow)
        }
    }

    @ViewBuilder
    private var content: some View {
        if let snapshot = dashboard.snapshot {
            TimelineView(.everyMinute) { context in
                NowBoardList(
                    board: NowBoard(dashboard: snapshot, now: context.date),
                    comingUp: comingUp,
                    feedURL: feedURL,
                    now: context.date,
                    notice: NowNotice(
                        source: dashboard.source, phase: dashboard.phase,
                        isIncompatible: dashboard.isIncompatible),
                    fetchedAt: dashboard.fetchedAt,
                    retry: refresh
                )
            }
            .overlay(alignment: .bottom) {
                NowSavedCopyNotice(dashboard: dashboard)
            }
            .refreshableScreen(action: refresh)
            .task(id: dashboard.fetchedAt) {
                await comingUp.reload()
            }
        } else if let status = NowStatus(phase: dashboard.phase, isIncompatible: dashboard.isIncompatible) {
            ContentUnavailableView {
                Label {
                    Text(status == .serviceNeedsUpdate ? .Now.statusIncompatibleTitle : .Now.unavailableTitle)
                } icon: {
                    Image(systemName: "exclamationmark.triangle")
                }
            } description: {
                Text(NowStatusBanner.message(for: status))
            } actions: {
                if status != .serviceNeedsUpdate {
                    Button(.Now.retry) {
                        Task { await dashboard.refresh() }
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
        } else {
            ProgressView {
                Text(.Now.loading)
            }
        }
    }

    /// Reloads the dashboard, then Coming Up's calendar range.
    private func refresh() async {
        await dashboard.refresh()
        await comingUp.reload()
    }
}
