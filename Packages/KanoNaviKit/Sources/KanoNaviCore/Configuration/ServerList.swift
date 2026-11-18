import Foundation

/// The servers the app can read and the one it reads: the built-in servers
/// first, then the ones the person added, in the order they were added.
public struct ServerList: Equatable, Sendable {
    /// Never empty; the first is the default.
    public let builtIn: [ServiceServer]
    public private(set) var custom: [ServiceServer]
    public private(set) var selectedID: ServiceServer.ID

    /// - Parameters:
    ///   - builtIn: The built-in servers, the default first. It must not be
    ///     empty.
    ///   - custom: Saved servers the person added. One whose address repeats
    ///     an earlier server's is dropped.
    ///   - selectedID: The saved selection; an unknown one selects the
    ///     default.
    public init(builtIn: [ServiceServer], custom: [ServiceServer] = [], selectedID: ServiceServer.ID? = nil) {
        precondition(builtIn.isEmpty == false, "A server list needs a built-in server.")
        self.builtIn = builtIn
        var seen = Set(builtIn.map(\.baseURL))
        self.custom = custom.filter { $0.builtIn == nil && seen.insert($0.baseURL).inserted }
        self.selectedID = builtIn[0].id
        if let selectedID {
            select(selectedID)
        }
    }

    public var all: [ServiceServer] {
        builtIn + custom
    }

    public var selected: ServiceServer {
        all.first { $0.id == selectedID } ?? builtIn[0]
    }

    /// Selects a listed server; an unknown ID changes nothing.
    public mutating func select(_ id: ServiceServer.ID) {
        guard all.contains(where: { $0.id == id }) else { return }
        selectedID = id
    }

    /// Adds a server and returns it. An empty name becomes the address's
    /// host.
    public mutating func add(name: String, baseURL: URL) throws(ServerListError) -> ServiceServer {
        if let existing = all.first(where: { $0.baseURL == baseURL }) {
            throw .duplicate(existing.id)
        }
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let server = ServiceServer.custom(
            name: trimmed.isEmpty ? ServerAddress.display(baseURL) : trimmed,
            baseURL: baseURL
        )
        custom.append(server)
        return server
    }

    /// Removes a server the person added. Removing the selected one selects
    /// the default; a built-in server stays.
    public mutating func remove(_ id: ServiceServer.ID) {
        custom.removeAll { $0.id == id }
        if selectedID == id {
            selectedID = builtIn[0].id
        }
    }
}
