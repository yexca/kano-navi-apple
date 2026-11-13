import Foundation

/// `GET /api/works/uploads`: the stored data of the Works upload list, keyed by
/// the upload ID of `/api/works/upload-list`, and the videos dated after it.
public struct WorksUploadsResponse: Codable, Equatable, Sendable {
    /// The upload list's date.
    public var updatedAt: JapanDate
    public var revision: Int
    /// Each upload with a ready cover or a stored video, by upload ID.
    public var uploads: [String: WorksUploadState]
    /// At most 48 stored videos dated after `updatedAt`, newest first.
    public var recent: [WorksRecentUpload]
    /// How many recent videos there are in all.
    public var recentTotal: Int
}
