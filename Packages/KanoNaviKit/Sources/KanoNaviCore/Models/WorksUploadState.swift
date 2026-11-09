import Foundation

public struct WorksUploadState: Codable, Equatable, Sendable {
    public var cover: WorksUploadCover?
    public var videos: [WorksUploadVideo]
}
