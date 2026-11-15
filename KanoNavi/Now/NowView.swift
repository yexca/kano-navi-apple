import KanoNaviCore
import SwiftUI

/// The Now tab: what is live or next, the next two weeks' entries, sales,
/// the latest video and a line on how fresh the data is. See
/// `docs/architecture/board-and-timelines.md`.
struct NowView: View {
    @Environment(\.services) private var services

    var body: some View {
        NowScreen(calendar: services?.calendar, feedURL: services?.client.calendarSubscriptionURL)
    }
}

#Preview {
    NowView()
        .environment(DashboardStore(client: APIClient(configuration: .main, cache: MemoryResponseCache())))
        .environment(AppRouter())
}
