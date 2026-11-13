import Foundation

/// Bounded snapshot of previously observed dashboard and calendar items.
public struct NotificationBaseline: Codable, Equatable, Sendable {
    public static let defaultCapacity = 1000

    public var establishedAt: Date
    public var lastRevision: Int?
    public var lastLiveNowKey: String?
    public var seenPostIDs: [String]
    public var seenVideoOrder: [String]
    public var seenVideoShelfGroups: [String: String]
    public var seenEventOrder: [String]
    public var seenEvents: [String: RecordedEventSnapshot]

    public init(
        establishedAt: Date,
        lastRevision: Int? = nil,
        lastLiveNowKey: String? = nil,
        seenPostIDs: [String] = [],
        seenVideoOrder: [String] = [],
        seenVideoShelfGroups: [String: String] = [:],
        seenEventOrder: [String] = [],
        seenEvents: [String: RecordedEventSnapshot] = [:]
    ) {
        self.establishedAt = establishedAt
        self.lastRevision = lastRevision
        self.lastLiveNowKey = lastLiveNowKey
        self.seenPostIDs = seenPostIDs
        self.seenVideoOrder = seenVideoOrder
        self.seenVideoShelfGroups = seenVideoShelfGroups
        self.seenEventOrder = seenEventOrder
        self.seenEvents = seenEvents
    }

    public mutating func recordPost(_ id: String, capacity: Int = Self.defaultCapacity) {
        if let index = seenPostIDs.firstIndex(of: id) {
            seenPostIDs.remove(at: index)
        }
        seenPostIDs.append(id)
        if seenPostIDs.count > capacity {
            seenPostIDs.removeFirst(seenPostIDs.count - capacity)
        }
    }

    public mutating func recordVideo(
        _ id: String,
        shelfGroup: String,
        capacity: Int = Self.defaultCapacity
    ) {
        if let index = seenVideoOrder.firstIndex(of: id) {
            seenVideoOrder.remove(at: index)
        }
        seenVideoOrder.append(id)
        seenVideoShelfGroups[id] = shelfGroup
        if seenVideoOrder.count > capacity {
            let overflow = seenVideoOrder.prefix(seenVideoOrder.count - capacity)
            for evicted in overflow {
                seenVideoShelfGroups.removeValue(forKey: evicted)
            }
            seenVideoOrder.removeFirst(seenVideoOrder.count - capacity)
        }
    }

    public mutating func recordEvent(
        _ id: String,
        snapshot: RecordedEventSnapshot,
        capacity: Int = Self.defaultCapacity
    ) {
        if let index = seenEventOrder.firstIndex(of: id) {
            seenEventOrder.remove(at: index)
        }
        seenEventOrder.append(id)
        seenEvents[id] = snapshot
        if seenEventOrder.count > capacity {
            let overflow = seenEventOrder.prefix(seenEventOrder.count - capacity)
            for evicted in overflow {
                seenEvents.removeValue(forKey: evicted)
            }
            seenEventOrder.removeFirst(seenEventOrder.count - capacity)
        }
    }
}
