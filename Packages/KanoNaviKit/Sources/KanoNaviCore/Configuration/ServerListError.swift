/// Why a server cannot be added to a ``ServerList``.
public enum ServerListError: Error, Equatable, Sendable {
    /// The list already has a server at this address, the associated ID.
    case duplicate(ServiceServer.ID)
}
