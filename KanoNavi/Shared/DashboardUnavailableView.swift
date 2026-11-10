import KanoNaviCore
import SwiftUI

/// Shown by a tab built on the dashboard while there is no snapshot at all:
/// the reason it could not load with Try Again, or loading. `extra` adds an
/// action, such as a link to the tab's archive.
struct DashboardUnavailableView<Extra: View>: View {
    let dashboard: DashboardStore
    @ViewBuilder var extra: Extra

    var body: some View {
        if let status = NowStatus(phase: dashboard.phase, isIncompatible: dashboard.isIncompatible) {
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
                    Button(.Now.retry, action: retry)
                        .buttonStyle(.borderedProminent)
                }
                extra
            }
        } else {
            ProgressView {
                Text(.Now.loading)
            }
        }
    }

    private func retry() {
        Task { await dashboard.refresh() }
    }
}
