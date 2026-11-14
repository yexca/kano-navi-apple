import KanoNaviCore
import SwiftUI

/// A list section saying that the dashboard data below it is not a fresh
/// read because a refresh failed, with the Now tab's wording. Nothing when
/// the data is fresh or is the saved copy being updated, which
/// `NowSavedCopyNotice` marks over the list without moving it.
struct DashboardNoticeSection: View {
    let dashboard: DashboardStore

    var body: some View {
        switch NowNotice(
            source: dashboard.source, phase: dashboard.phase, isIncompatible: dashboard.isIncompatible)
        {
        case .failed(let status, let isSavedCopy):
            Section {
                NowStatusBanner(
                    status: status, isSavedCopy: isSavedCopy, fetchedAt: dashboard.fetchedAt,
                    retry: dashboard.refresh)
            }
        case .savedCopy, nil:
            EmptyView()
        }
    }
}
