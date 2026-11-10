/// What an Upcoming widget entry shows.
nonisolated enum UpcomingContent: Equatable, Sendable {
    /// Calendar data, fresh or cached.
    case schedule(WidgetSchedule)
    /// The read failed and nothing is cached.
    case unavailable
}
