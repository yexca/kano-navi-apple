import Foundation

public enum LiveStatus: Codable, Equatable, Sendable { case live, upcoming, ended, unknown(String)
    public init(from decoder: Decoder) throws { let value = try decoder.singleValueContainer().decode(String.self); self = switch value { case "live": .live; case "upcoming": .upcoming; case "ended": .ended; default: .unknown(value) } }
    public func encode(to encoder: Encoder) throws { var c = encoder.singleValueContainer(); try c.encode(rawValue) }
    public var rawValue: String { switch self { case .live: "live"; case .upcoming: "upcoming"; case .ended: "ended"; case .unknown(let v): v } }
}

public enum TranslationOrigin: Codable, Equatable, Sendable { case manual, platform, machine, unknown(String)
    public init(from decoder: Decoder) throws { let v = try decoder.singleValueContainer().decode(String.self); self = switch v { case "manual": .manual; case "platform": .platform; case "machine": .machine; default: .unknown(v) } }
    public func encode(to encoder: Encoder) throws { var c = encoder.singleValueContainer(); try c.encode(rawValue) }
    public var rawValue: String { switch self { case .manual: "manual"; case .platform: "platform"; case .machine: "machine"; case .unknown(let v): v } }
}

public enum EventPlatform: Codable, Equatable, Sendable { case youtube, bilibili, other, unknown(String)
    public init(from decoder: Decoder) throws { let v = try decoder.singleValueContainer().decode(String.self); self = switch v { case "youtube": .youtube; case "bilibili": .bilibili; case "other": .other; default: .unknown(v) } }
    public func encode(to encoder: Encoder) throws { var c = encoder.singleValueContainer(); try c.encode(rawValue) }
    public var rawValue: String { switch self { case .youtube: "youtube"; case .bilibili: "bilibili"; case .other: "other"; case .unknown(let v): v } }
}

public enum VideoAvailability: Codable, Equatable, Sendable { case `public`, unlisted, members, `private`, removed, unknown(String)
    public init(from decoder: Decoder) throws { let v = try decoder.singleValueContainer().decode(String.self); self = switch v { case "public": .public; case "unlisted": .unlisted; case "members": .members; case "private": .private; case "removed": .removed; default: .unknown(v) } }
    public func encode(to encoder: Encoder) throws { var c = encoder.singleValueContainer(); try c.encode(rawValue) }
    public var rawValue: String { switch self { case .public: "public"; case .unlisted: "unlisted"; case .members: "members"; case .private: "private"; case .removed: "removed"; case .unknown(let v): v } }
}

public enum SaleMark: Codable, Equatable, Sendable { case opens, closes, unknown(String)
    public init(from decoder: Decoder) throws { let v = try decoder.singleValueContainer().decode(String.self); self = switch v { case "opens": .opens; case "closes": .closes; default: .unknown(v) } }
    public func encode(to encoder: Encoder) throws { var c = encoder.singleValueContainer(); try c.encode(rawValue) }
    public var rawValue: String { switch self { case .opens: "opens"; case .closes: "closes"; case .unknown(let v): v } }
}
