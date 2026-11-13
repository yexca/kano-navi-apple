/// A screen the Journey pushes onto the More tab's navigation stack.
nonisolated enum JourneyDestination: Hashable {
    /// The detail of the milestone with this ID.
    case milestone(String)
}
