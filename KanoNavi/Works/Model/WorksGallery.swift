import Foundation
import KanoNaviCore

/// The pictures of one release or participation work, in the order the
/// viewer pages through them. A file that several places show, such as an
/// edition's cover that is also the release's, is one picture.
nonisolated struct WorksGallery: Equatable, Sendable {
    let pictures: [WorksPicture]

    /// The pictures of `images` in order, each file once.
    init(images: [WorksImage]) {
        var seen: Set<String> = []
        pictures = images.map(WorksPicture.init).filter { seen.insert($0.id).inserted }
    }

    /// A release's pictures: its covers, its disc photos, then each
    /// edition's covers, bonus images, disc photos and store bonus images,
    /// then the store bonus images for any edition.
    init(release: WorksRelease) {
        var images = release.covers + Self.discPhotos(of: release)
        for edition in release.editions {
            images += edition.covers + edition.bonusImages + edition.discs.map(\.image)
            images += edition.storeBonuses.flatMap(\.images)
        }
        images += release.storeBonuses.flatMap(\.images)
        self.init(images: images)
    }

    /// The photos of the discs every edition shares, each file once: the
    /// per-disc photos, then the shelf's disc photo when it is another file.
    static func discPhotos(of release: WorksRelease) -> [WorksImage] {
        WorksGallery(images: release.discs.map(\.image) + [release.disc].compactMap(\.self)).pictures.map(
            \.image)
    }

    /// The picture that shows `image`'s file.
    func picture(for image: WorksImage) -> WorksPicture? {
        let id = image.url.absoluteString
        return pictures.first { $0.id == id }
    }
}
