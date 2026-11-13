import Foundation
import KanoNaviCore

/// One image of the Works collection as the full-screen viewer pages
/// through it. A file is one picture however many places show it.
nonisolated struct WorksPicture: Equatable, Identifiable, Sendable {
    let image: WorksImage

    /// The file's address.
    var id: String { image.url.absoluteString }

    var source: MediaImageSource {
        MediaImageSource(url: image.url, width: image.width, height: image.height)
    }
}
