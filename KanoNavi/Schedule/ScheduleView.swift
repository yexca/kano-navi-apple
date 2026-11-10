import KanoNaviCore
import SwiftUI

/// The Schedule tab. See `docs/design.md`.
struct ScheduleView: View {
    @Environment(\.services) private var services

    var body: some View {
        if let services {
            ScheduleScreen(
                loader: { [calendar = services.calendar] month in
                    try await calendar.month(containing: month)
                },
                feedURL: services.client.calendarSubscriptionURL)
        } else {
            FeaturePlaceholder(title: .tabSchedule)
        }
    }
}

#Preview {
    ScheduleView()
        .environment(AppRouter())
}
