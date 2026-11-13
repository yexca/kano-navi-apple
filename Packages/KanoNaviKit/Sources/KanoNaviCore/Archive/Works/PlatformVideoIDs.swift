import Foundation

/// Platform video IDs of one recording: a Works track's `listen` and an
/// upload-list entry's videos.
public struct PlatformVideoIDs: Codable, Hashable, Sendable {
    public var niconico: String?
    public var youtube: [String]
    /// YouTube videos only channel members can watch.
    public var youtubeMembers: [String]
    public var bilibili: String?

    public init(
        niconico: String? = nil, youtube: [String] = [], youtubeMembers: [String] = [],
        bilibili: String? = nil
    ) {
        self.niconico = niconico
        self.youtube = youtube
        self.youtubeMembers = youtubeMembers
        self.bilibili = bilibili
    }

    /// The watch pages in the web board's order: niconico, YouTube, members-only
    /// YouTube, then Bilibili. An ID that is not a plain platform ID is left out.
    public var links: [PlatformVideoLink] {
        let candidates: [PlatformVideoLink?] =
            [niconico.flatMap { PlatformVideoLink(platform: .niconico, id: $0) }]
            + youtube.map { PlatformVideoLink(platform: .youtube, id: $0) }
            + youtubeMembers.map { PlatformVideoLink(platform: .youtube, id: $0, isMembersOnly: true) }
            + [bilibili.flatMap { PlatformVideoLink(platform: .bilibili, id: $0) }]
        return candidates.compactMap(\.self)
    }

    /// Whether the recording has no video on any platform.
    public var isEmpty: Bool {
        niconico == nil && youtube.isEmpty && youtubeMembers.isEmpty && bilibili == nil
    }
}

/// A video platform a Works upload is on.
public enum VideoPlatform: String, Codable, Hashable, Sendable, CaseIterable {
    case niconico
    case youtube
    case bilibili
}

/// A video's watch page built from its platform ID.
public struct PlatformVideoLink: Hashable, Sendable {
    public var platform: VideoPlatform
    public var id: String
    /// Only channel members can watch it (a `youtubeMembers` ID).
    public var isMembersOnly: Bool
    public var url: URL

    /// `nil` when `id` is empty or holds anything but ASCII letters, digits, `-` and `_`.
    public init?(platform: VideoPlatform, id: String, isMembersOnly: Bool = false) {
        guard let url = Self.watchURL(platform: platform, id: id) else { return nil }
        self.platform = platform
        self.id = id
        self.isMembersOnly = isMembersOnly
        self.url = url
    }

    /// `https://www.nicovideo.jp/watch/<id>`, `https://www.youtube.com/watch?v=<id>`
    /// or `https://www.bilibili.com/video/<id>`; `nil` for an ID that is not a
    /// plain platform ID.
    public static func watchURL(platform: VideoPlatform, id: String) -> URL? {
        let allowed = id.unicodeScalars.allSatisfy {
            $0.isASCII && (CharacterSet.alphanumerics.contains($0) || $0 == "-" || $0 == "_")
        }
        guard id.isEmpty == false, allowed else { return nil }
        return switch platform {
        case .niconico: URL(string: "https://www.nicovideo.jp/watch/" + id)
        case .youtube: URL(string: "https://www.youtube.com/watch?v=" + id)
        case .bilibili: URL(string: "https://www.bilibili.com/video/" + id)
        }
    }
}
