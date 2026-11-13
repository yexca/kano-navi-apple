/// The order a Works list is shown in. The collection lists its items oldest
/// first; a phone shows the newest first unless asked otherwise.
nonisolated enum WorksOrder: String, CaseIterable, Sendable {
    case newestFirst
    case oldestFirst
}
