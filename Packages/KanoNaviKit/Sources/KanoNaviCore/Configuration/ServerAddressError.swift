/// Why a typed server address cannot be used.
public enum ServerAddressError: Error, Equatable, Sendable {
    case empty
    /// The address names a scheme other than HTTPS.
    case notHTTPS
    case invalid
}
