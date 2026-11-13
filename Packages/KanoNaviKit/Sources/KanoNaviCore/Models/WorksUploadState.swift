import Foundation

/// The stored data of one upload.
public struct WorksUploadState: Codable, Equatable, Sendable {
    public var cover: WorksUploadCover?
    /// The stored YouTube and Bilibili videos of the upload, in list order.
    public var videos: [WorksUploadVideo]
}
