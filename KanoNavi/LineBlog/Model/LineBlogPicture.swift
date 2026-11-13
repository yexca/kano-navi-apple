import Foundation
import KanoNaviCore

/// A picture of an article that opens in the image viewer.
nonisolated struct LineBlogPicture: Identifiable, Hashable, Sendable {
    /// The picture's position among the article's viewer pictures, from 0.
    let id: Int
    let source: MediaImageSource
    /// What the picture shows, when the archive says.
    let alt: String?
    /// How the picture was found when it was added after the recovery
    /// archive.
    let recovery: LineBlogImageRecovery?
    /// Where the archived bytes came from (provenance).
    let sourceURL: URL?
    /// The page the picture linked to in the article.
    let link: URL?
}
