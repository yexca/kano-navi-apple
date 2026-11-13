import Foundation

/// A personal release. Titles and names are plain strings as the collection
/// writes them; rendered wording (label, catalog, captions, credits) is
/// localized text, `nil` when the collection gives none.
public struct WorksRelease: Codable, Equatable, Sendable, Identifiable {
    /// Release ID: a Japan date and a title hash.
    public var id: String
    /// The first Japan release date.
    public var date: JapanDate
    public var title: String
    public var format: WorksReleaseFormat
    /// Released for download or streaming.
    public var digital: Bool
    /// Every edition was withdrawn.
    public var cancelled: Bool
    /// The unit name of a unit work.
    public var unit: String?
    public var label: LocalizedText?
    public var catalog: LocalizedText?
    public var covers: [WorksImage]
    /// The disc photo for the shelf.
    public var disc: WorksImage?
    /// The record shows the cover printed on a disc instead of a drawn one.
    public var printedDisc: Bool
    /// The figure cut out of the cover on a transparent ground.
    public var cutout: WorksImage?
    /// The tracks every edition shares.
    public var tracks: [WorksTrack]
    /// Photos of the shared discs.
    public var discs: [WorksDiscImage]
    /// Editions on sale; empty for a release sold in one plain version.
    public var editions: [WorksEdition]
    /// Bonuses for any edition.
    public var storeBonuses: [WorksStoreBonus]
    /// Streaming and download listings for any edition.
    public var stores: [WorksStoreListing]

    func resolvingMedia(against baseURL: URL) -> WorksRelease {
        var value = self
        value.covers = covers.resolvingMedia(against: baseURL)
        value.disc = disc?.resolvingMedia(against: baseURL)
        value.cutout = cutout?.resolvingMedia(against: baseURL)
        value.discs = discs.map { $0.resolvingMedia(against: baseURL) }
        value.editions = editions.map { $0.resolvingMedia(against: baseURL) }
        value.storeBonuses = storeBonuses.map { $0.resolvingMedia(against: baseURL) }
        return value
    }
}

/// One edition of a personal release, with its own full track list.
public struct WorksEdition: Codable, Equatable, Sendable {
    public var name: LocalizedText?
    public var catalog: LocalizedText?
    public var price: LocalizedText?
    public var format: LocalizedText?
    public var packaging: LocalizedText?
    /// Its own Japan date when it came out after the release.
    public var date: JapanDate?
    public var cancelled: Bool
    /// The JAN code, empty when unknown.
    public var jan: String
    public var covers: [WorksImage]
    public var bonuses: [LocalizedText]
    public var bonusImages: [WorksImage]
    public var storeBonuses: [WorksStoreBonus]
    public var stores: [WorksStoreListing]
    public var tracks: [WorksTrack]
    public var discs: [WorksDiscImage]
    public var printedDisc: Bool

    func resolvingMedia(against baseURL: URL) -> WorksEdition {
        var value = self
        value.covers = covers.resolvingMedia(against: baseURL)
        value.bonusImages = bonusImages.resolvingMedia(against: baseURL)
        value.storeBonuses = storeBonuses.map { $0.resolvingMedia(against: baseURL) }
        value.discs = discs.map { $0.resolvingMedia(against: baseURL) }
        return value
    }
}

/// A track of a personal release or edition.
public struct WorksTrack: Codable, Equatable, Sendable {
    public var disc: Int
    public var discLabel: LocalizedText?
    public var no: Int
    public var title: String
    public var credit: LocalizedText?
    public var note: LocalizedText?
    /// The uploads of the same recording, or `nil`.
    public var listen: PlatformVideoIDs?
}

/// The photo of one disc.
public struct WorksDiscImage: Codable, Equatable, Sendable {
    public var disc: Int
    public var image: WorksImage

    func resolvingMedia(against baseURL: URL) -> WorksDiscImage {
        WorksDiscImage(disc: disc, image: image.resolvingMedia(against: baseURL))
    }
}

/// A store's bonus for buying a release or edition.
public struct WorksStoreBonus: Codable, Equatable, Sendable {
    public var store: LocalizedText
    public var item: LocalizedText
    public var images: [WorksImage]

    func resolvingMedia(against baseURL: URL) -> WorksStoreBonus {
        var value = self
        value.images = images.resolvingMedia(against: baseURL)
        return value
    }
}

/// The streaming and download links of one item.
public struct WorksStoreListing: Codable, Equatable, Sendable {
    /// The item, or `nil` for the main item.
    public var item: LocalizedText?
    public var links: [WorksStoreLink]
}

/// One streaming or download store page.
public struct WorksStoreLink: Codable, Equatable, Sendable {
    /// Platform code, such as `apple_music` or `spotify`.
    public var platform: String
    public var url: URL
    /// A hi-res listing.
    public var hiRes: Bool
}
