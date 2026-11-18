/// Why ``ServerCheck`` did not confirm a server.
public enum ServerCheckError: Error, Equatable, Sendable {
    /// No response arrived.
    case unreachable
    /// A response arrived, but not a dashboard the app can read.
    case incompatible
    case cancelled
}
