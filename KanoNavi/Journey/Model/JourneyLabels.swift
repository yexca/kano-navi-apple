import Foundation
import KanoNaviCore

/// The interface wording of the Journey's codes. Every unknown code gets a
/// neutral label; none shows its raw code.
nonisolated enum JourneyLabels {
    /// A further link's label.
    static func link(_ label: JourneyLinkLabel) -> LocalizedStringResource {
        switch label {
        case .agency: .Journey.linkAgency
        case .x: .Journey.linkX
        case .cancelledRelease: .Journey.linkCancelledRelease
        case .unknown: .Journey.linkOther
        }
    }

    /// What an image shows, as a gallery filter and a caption's kicker.
    static func category(_ category: JourneyMediaCategory) -> LocalizedStringResource {
        switch category {
        case .artwork: .Journey.categoryArtwork
        case .goods: .Journey.categoryGoods
        case .frame: .Journey.categoryFrame
        case .model: .Journey.categoryModel
        case .cover: .Journey.categoryCover
        case .unknown: .Journey.categoryOther
        }
    }

    /// What an image's date is the date of.
    static func dateKind(_ kind: JourneyMediaDateKind) -> LocalizedStringResource {
        switch kind {
        case .post: .Journey.dateKindPost
        case .announcement: .Journey.dateKindAnnouncement
        case .publication: .Journey.dateKindPublication
        case .stream: .Journey.dateKindStream
        case .outfit: .Journey.dateKindOutfit
        case .capture: .Journey.dateKindCapture
        case .release: .Journey.dateKindRelease
        case .unknown: .Journey.dateKindOther
        }
    }

    /// Who published an image's file.
    static func sourceKind(_ kind: JourneyMediaSourceKind) -> LocalizedStringResource {
        switch kind {
        case .artist: .Journey.sourceKindArtist
        case .organizer: .Journey.sourceKindOrganizer
        case .creator: .Journey.sourceKindCreator
        case .video: .Journey.sourceKindVideo
        case .streamArchive: .Journey.sourceKindStreamArchive
        case .shop: .Journey.sourceKindShop
        case .brand: .Journey.sourceKindBrand
        case .agency: .Journey.sourceKindAgency
        case .officialCover: .Journey.sourceKindOfficialCover
        case .thirdPartyCover: .Journey.sourceKindThirdPartyCover
        case .unknown: .Journey.sourceKindOther
        }
    }

    /// The provenance note of a `note` code, or `nil` for no note and for a
    /// code the app does not know yet: a note is a whole sentence about one
    /// image, which a neutral label could not stand in for.
    static func note(_ code: String?) -> LocalizedStringResource? {
        switch code {
        case "cover": .Journey.noteCover
        case "thirdPartyCover": .Journey.noteThirdPartyCover
        case "cancelledRelease": .Journey.noteCancelledRelease
        case "artwork": .Journey.noteArtwork
        case "frame": .Journey.noteFrame
        case "outfitMerch": .Journey.noteOutfitMerch
        case "mahoroDebut": .Journey.noteMahoroDebut
        case "modelAnnouncement": .Journey.noteModelAnnouncement
        case "siteCapture": .Journey.noteSiteCapture
        case "station": .Journey.noteStation
        case "recap": .Journey.noteRecap
        case "xr": .Journey.noteXR
        default: nil
        }
    }

    /// Every `note` code the catalog words.
    static let noteCodes = [
        "cover", "thirdPartyCover", "cancelledRelease", "artwork", "frame", "outfitMerch", "mahoroDebut",
        "modelAnnouncement", "siteCapture", "station", "recap", "xr",
    ]

    /// Who scanned or gave a release cover, or `nil` when there is nothing
    /// to say (no credit, or an unknown role without a name).
    static func coverCredit(_ credit: WorksImageCredit?) -> LocalizedStringResource? {
        guard let credit else { return nil }
        let name = credit.name ?? ""
        switch credit.role {
        case .scan: return name.isEmpty ? nil : .Journey.coverCreditScan(name)
        case .photo: return name.isEmpty ? nil : .Journey.coverCreditPhoto(name)
        case .fan: return .Journey.coverCreditFan
        case .unknown: return name.isEmpty ? nil : .Journey.coverCreditOther(name)
        }
    }

    /// The site a provenance address is on, such as `x.com`, for a link's
    /// label; `nil` when the address has no host.
    static func host(of url: URL) -> String? {
        guard let host = url.host(), host.isEmpty == false else { return nil }
        return host.hasPrefix("www.") ? String(host.dropFirst(4)) : host
    }
}
