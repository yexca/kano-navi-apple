import KanoNaviCore
import SwiftUI

/// The Schedule tab. See `docs/architecture/board-and-timelines.md`.
struct ScheduleView: View {
    @Environment(\.services) private var services
    @Environment(DashboardStore.self) private var dashboard: DashboardStore?

    var body: some View {
        if let services {
            ScheduleScreen(
                loader: { [calendar = services.calendar] month in
                    try await calendar.month(containing: month)
                },
                feedURL: services.client.calendarSubscriptionURL,
                revision: dashboard?.snapshot?.meta.revision
            )
            // Another server starts the screen over.
            .id(services.client.baseURL)
        } else {
            FeaturePlaceholder(title: .tabSchedule)
        }
    }
}

#Preview {
    ScheduleView()
        .environment(AppRouter())
}
