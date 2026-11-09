import Foundation

public struct Profile: Codable, Equatable, Sendable {
  public var displayName: String
  public var romanizedName: String
  public var bio: String
  public var avatarURL: URL?
  public var bannerURL: URL?
  public var xURL: URL
  public var youtubeURL: URL

  public init(
    displayName: String, romanizedName: String, bio: String, avatarURL: URL?, bannerURL: URL?,
    xURL: URL, youtubeURL: URL
  ) {
    self.displayName = displayName
    self.romanizedName = romanizedName
    self.bio = bio
    self.avatarURL = avatarURL
    self.bannerURL = bannerURL
    self.xURL = xURL
    self.youtubeURL = youtubeURL
  }

  enum CodingKeys: String, CodingKey {
    case displayName, romanizedName, bio
    case avatarURL = "avatarUrl"
    case bannerURL = "bannerUrl"
    case xURL = "xUrl"
    case youtubeURL = "youtubeUrl"
  }
}
