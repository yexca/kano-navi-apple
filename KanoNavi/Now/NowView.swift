import KanoNaviCore
import SwiftUI

/// The Now tab: what is live or next, today's and tomorrow's entries, sales,
/// the latest video and how fresh the data is. See `docs/design.md`.
///
/// `RootView` starts and stops the dashboard store with the scene; this view
/// only reads it and refreshes it on demand.
struct NowView: View {
    @Environment(DashboardStore.self) private var dashboard

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
                    now: context.date,
                    status: NowStatus(phase: dashboard.phase, isIncompatible: dashboard.isIncompatible),
                    fetchedAt: dashboard.fetchedAt,
                    retry: refresh
                )
            }
            .refreshable(action: refresh)
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
                        Task { await refresh() }
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

    private func refresh() async {
        await dashboard.refresh()
    }
}

#Preview {
    NowView()
        .environment(DashboardStore(client: APIClient(configuration: .main, cache: MemoryResponseCache())))
        .environment(AppRouter())
}
