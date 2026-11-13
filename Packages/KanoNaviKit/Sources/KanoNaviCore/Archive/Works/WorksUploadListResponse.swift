import Foundation

/// `GET /api/works/upload-list`: the collection's uploads, oldest first.
/// Join it with `WorksUploadsResponse` (`/api/works/uploads`) by upload ID for
/// covers and stored videos.
public struct WorksUploadListResponse: Codable, Equatable, Sendable {
    public var updatedAt: JapanDate
    public var uploads: [WorksUploadEntry]
}

/// One upload of the collection. Videos are platform IDs, never URLs; free
/// text is empty when there is none.
public struct WorksUploadEntry: Codable, Equatable, Sendable, Identifiable {
    public var id: String
    public var date: JapanDate
    public var song: String
    public var originalArtist: String
    public var kind: WorksUploadKind
    /// Who else took part, as written.
    public var with: String
    public var niconico: String?
    public var youtube: [String]
    /// Videos only channel members can watch.
    public var youtubeMembers: [String]
    public var bilibili: String?
    public var bilibiliTitle: String
    /// Names of the albums that include the recording, as written (not release IDs).
    public var albums: [String]
    /// A compilation's songs, as written.
    public var tracks: [String]

    /// The upload's platform IDs in the shape of a track's `listen`.
    public var videoIDs: PlatformVideoIDs {
        PlatformVideoIDs(
            niconico: niconico, youtube: youtube, youtubeMembers: youtubeMembers, bilibili: bilibili)
    }
}
