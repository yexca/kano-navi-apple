import Foundation

public struct ArchiveMonth: Codable, Equatable, Sendable {
  public var month: String
  public var total: Int
  public var counts: [String: Int]
  public init(month: String, total: Int, counts: [String: Int]) {
    self.month = month
    self.total = total
    self.counts = counts
  }
  enum CodingKeys: String, CodingKey { case month, total, counts, accountCounts, categoryCounts }
  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    month = try container.decode(String.self, forKey: .month)
    total = try container.decode(Int.self, forKey: .total)
    counts =
      try container.decodeIfPresent([String: Int].self, forKey: .counts)
      ?? container.decodeIfPresent([String: Int].self, forKey: .accountCounts)
      ?? container.decodeIfPresent([String: Int].self, forKey: .categoryCounts)
      ?? [:]
  }
  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(month, forKey: .month)
    try container.encode(total, forKey: .total)
    try container.encode(counts, forKey: .counts)
  }
}
