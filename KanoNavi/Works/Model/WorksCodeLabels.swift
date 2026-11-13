import Foundation
import KanoNaviCore

/// The Works collection's codes in words, from the feature's String Catalog.
/// A code the app does not know gets a neutral label, never the raw code.
nonisolated enum WorksCodeLabels {
    /// A personal release's format.
    static func format(_ format: WorksReleaseFormat) -> LocalizedStringResource {
        switch format {
        case .album: .Works.formatAlbum
        case .single: .Works.formatSingle
        case .ep: .Works.formatEp
        case .doujin: .Works.formatDoujin
        case .unknown: .Works.formatOther
        }
    }

    /// The choice of the release filter for a format code or
    /// `WorksCodeFilter.otherCode`.
    static func formatFilter(_ code: String) -> LocalizedStringResource {
        code == WorksCodeFilter.otherCode ? .Works.filterOther : format(WorksReleaseFormat(code: code))
    }

    /// Kano's part in a participation work.
    static func role(_ role: WorksParticipationRole) -> LocalizedStringResource {
        switch role {
        case .vocal: .Works.roleVocal
        case .lyrics: .Works.roleLyrics
        case .composition: .Works.roleComposition
        case .voice: .Works.roleVoice
        case .guest: .Works.roleGuest
        case .unknown: .Works.roleOther
        }
    }

    /// The form of a participation work, an open code.
    static func form(_ code: String) -> LocalizedStringResource {
        switch code {
        case "digital": .Works.formDigital
        case "bonus": .Works.formBonus
        case "drama": .Works.formDrama
        case "cdr": .Works.formCdr
        case "boxSet": .Works.formBoxSet
        case "notForSale": .Works.formNotForSale
        case "promo": .Works.formPromo
        default: .Works.formOther
        }
    }

    /// A further credit of Kano's on a participation track.
    static func kanoCredit(_ credit: WorksKanoCredit) -> LocalizedStringResource {
        switch credit {
        case .lyrics: .Works.creditLyrics
        case .composition: .Works.creditComposition
        case .arrangement: .Works.creditArrangement
        case .animation: .Works.creditAnimation
        case .other, .unknown: .Works.creditOther
        }
    }

    /// The kind of an upload.
    static func uploadKind(_ kind: WorksUploadKind) -> LocalizedStringResource {
        switch kind {
        case .cover: .Works.kindCover
        case .original: .Works.kindOriginal
        case .mv: .Works.kindMv
        case .project: .Works.kindProject
        case .compilation: .Works.kindCompilation
        case .game: .Works.kindGame
        case .composition: .Works.kindComposition
        case .unknown: .Works.kindOther
        }
    }

    /// The choice of the upload filter for a kind code or
    /// `WorksCodeFilter.otherCode`.
    static func uploadKindFilter(_ code: String) -> LocalizedStringResource {
        code == WorksCodeFilter.otherCode ? .Works.filterOther : uploadKind(WorksUploadKind(code: code))
    }

    /// A streaming or download store, an open code.
    static func storePlatform(_ code: String) -> LocalizedStringResource {
        switch code {
        case "smart_link": .Works.storeSmartLink
        case "apple_music": .Works.storeAppleMusic
        case "spotify": .Works.storeSpotify
        case "amazon_music": .Works.storeAmazonMusic
        case "line_music": .Works.storeLineMusic
        case "youtube_music": .Works.storeYoutubeMusic
        case "awa": .Works.storeAwa
        case "itunes": .Works.storeItunes
        case "mora": .Works.storeMora
        case "recochoku": .Works.storeRecochoku
        case "ototoy": .Works.storeOtotoy
        case "qq_music": .Works.storeQqMusic
        case "kugou": .Works.storeKugou
        case "label_page": .Works.storeLabelPage
        default: .Works.storeOther
        }
    }

    /// The credit an image's contributor asks for, with the name when the
    /// record gives one.
    static func imageCredit(_ credit: WorksImageCredit) -> LocalizedStringResource {
        let name = credit.name.flatMap { $0.isEmpty ? nil : $0 }
        switch (credit.role, name) {
        case (.scan, let name?): return .Works.imageCreditScanBy(name)
        case (.scan, nil): return .Works.imageCreditScan
        case (.photo, let name?): return .Works.imageCreditPhotoFrom(name)
        case (.photo, nil): return .Works.imageCreditPhoto
        case (.fan, _): return .Works.imageCreditFan
        case (.unknown, let name?): return .Works.imageCreditBy(name)
        case (.unknown, nil): return .Works.imageCreditOther
        }
    }

    /// A video platform an upload is on.
    static func platform(_ platform: VideoPlatform) -> LocalizedStringResource {
        switch platform {
        case .niconico: .Works.platformNiconico
        case .youtube: .Works.platformYoutube
        case .bilibili: .Works.platformBilibili
        }
    }

    /// Why a video newer than the collection is listed.
    static func recentOrigin(_ origin: WorksRecentOrigin) -> LocalizedStringResource {
        switch origin {
        case .auto: .Works.recentOriginAuto
        case .operator: .Works.recentOriginOperator
        case .unknown: .Works.recentOriginOther
        }
    }
}
