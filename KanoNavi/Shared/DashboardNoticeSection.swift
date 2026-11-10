import KanoNaviCore
import SwiftUI

/// A list section saying why the dashboard data below it is not a fresh
/// read, with the Now tab's wording: the saved copy from this device, or a
/// failed refresh. Nothing when the data is fresh.
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
        case .savedCopy(let isUpdating):
            Section {
                NowSavedCopyNotice(isUpdating: isUpdating, fetchedAt: dashboard.fetchedAt)
            }
        case nil:
            EmptyView()
        }
    }
}
