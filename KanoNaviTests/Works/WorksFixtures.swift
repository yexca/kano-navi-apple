import Foundation
import KanoNaviCore

/// Synthetic Works records in the API's JSON shape, decoded with the API's
/// own decoder. Names are made up and URLs use the reserved `example.com`
/// domain; nothing here is archive data.
enum WorksFixtures {
    /// A localized text object; a missing language is `null`, as the API writes it.
    static func text(_ en: String?, ja: String? = nil, zh: String? = nil) -> [String: Any] {
        ["en": en ?? NSNull(), "ja": ja ?? NSNull(), "zh-CN": zh ?? NSNull()]
    }

    static func image(
        _ name: String, caption: String? = nil, sourceURL: String? = nil, sourceLabel: String? = nil,
        credit: [String: Any]? = nil, thirdParty: Bool? = false
    ) -> [String: Any] {
        [
            "url": "https://example.com/media/works/" + name, "width": 600, "height": 600,
            "mimeType": "image/jpeg", "caption": caption.map { text($0) } ?? NSNull(),
            "sourceUrl": sourceURL ?? NSNull(), "sourceLabel": sourceLabel ?? NSNull(),
            "credit": credit ?? NSNull(), "thirdParty": thirdParty ?? NSNull(),
        ]
    }

    static func track(
        disc: Int = 1, no: Int, title: String? = nil, discLabel: String? = nil, listen: [String: Any]? = nil
    ) -> [String: Any] {
        [
            "disc": disc, "discLabel": discLabel.map { text($0) } ?? NSNull(), "no": no,
            "title": title ?? "Track \(disc)-\(no)", "credit": NSNull(), "note": NSNull(),
            "listen": listen ?? NSNull(),
        ]
    }

    static func discImage(_ disc: Int, _ name: String) -> [String: Any] {
        ["disc": disc, "image": image(name)]
    }

    static func edition(
        name: String? = "Edition", catalog: String? = nil, price: String? = nil, format: String? = nil,
        packaging: String? = nil, date: String? = nil, cancelled: Bool = false, jan: String = "",
        covers: [[String: Any]] = [], bonusImages: [[String: Any]] = [], storeBonuses: [[String: Any]] = [],
        tracks: [[String: Any]] = [], discs: [[String: Any]] = []
    ) -> [String: Any] {
        [
            "name": name.map { text($0) } ?? NSNull(), "catalog": catalog.map { text($0) } ?? NSNull(),
            "price": price.map { text($0) } ?? NSNull(), "format": format.map { text($0) } ?? NSNull(),
            "packaging": packaging.map { text($0) } ?? NSNull(), "date": date ?? NSNull(),
            "cancelled": cancelled, "jan": jan, "covers": covers, "bonuses": [[String: Any]](),
            "bonusImages": bonusImages, "storeBonuses": storeBonuses, "stores": [[String: Any]](),
            "tracks": tracks, "discs": discs, "printedDisc": false,
        ]
    }

    static func storeBonus(_ store: String, images: [[String: Any]] = []) -> [String: Any] {
        ["store": text(store), "item": text("Bonus item"), "images": images]
    }

    static func release(
        id: String, date: String, format: String = "album", digital: Bool = false, cancelled: Bool = false,
        unit: String? = nil, covers: [[String: Any]] = [], disc: [String: Any]? = nil,
        tracks: [[String: Any]] = [], discs: [[String: Any]] = [], editions: [[String: Any]] = [],
        storeBonuses: [[String: Any]] = []
    ) throws -> WorksRelease {
        try decode(
            WorksRelease.self,
            [
                "id": id, "date": date, "title": "Synthetic " + id, "format": format, "digital": digital,
                "cancelled": cancelled, "unit": unit ?? NSNull(), "label": NSNull(), "catalog": NSNull(),
                "covers": covers, "disc": disc ?? NSNull(), "printedDisc": false, "cutout": NSNull(),
                "tracks": tracks, "discs": discs, "editions": editions, "storeBonuses": storeBonuses,
                "stores": [[String: Any]](),
            ])
    }

    static func participationTrack(
        disc: Int = 1, no: Int, kano: Bool = false, credits: [String] = []
    ) -> [String: Any] {
        [
            "disc": disc, "no": no, "title": "Track \(disc)-\(no)", "credit": "Example Artist", "kano": kano,
            "kanoCredits": credits,
        ]
    }

    static func participation(
        id: String, date: String = "2012-08-11", roles: [String] = ["vocal"], forms: [String] = [],
        unit: String? = nil, label: String = "", event: String = "", catalog: String = "",
        tracks: [[String: Any]] = []
    ) throws -> WorksParticipation {
        try decode(
            WorksParticipation.self,
            [
                "id": id, "date": date, "title": "Synthetic " + id, "roles": roles, "forms": forms,
                "unit": unit ?? NSNull(), "label": label, "event": event, "catalog": catalog,
                "sourceUrl": NSNull(), "cover": NSNull(), "tracks": tracks,
            ])
    }

    static func upload(
        id: String, date: String, song: String? = nil, kind: String = "cover", originalArtist: String = "",
        with partners: String = "", niconico: String? = nil, youtube: [String] = [],
        youtubeMembers: [String] = [], bilibili: String? = nil, bilibiliTitle: String = "",
        albums: [String] = [], tracks: [String] = []
    ) -> [String: Any] {
        [
            "id": id, "date": date, "song": song ?? "Song " + id, "originalArtist": originalArtist,
            "kind": kind, "with": partners, "niconico": niconico ?? NSNull(), "youtube": youtube,
            "youtubeMembers": youtubeMembers, "bilibili": bilibili ?? NSNull(),
            "bilibiliTitle": bilibiliTitle, "albums": albums, "tracks": tracks,
        ]
    }

    static func uploadList(_ uploads: [[String: Any]]) throws -> WorksUploadListResponse {
        try decode(WorksUploadListResponse.self, ["updatedAt": "2026-11-07", "uploads": uploads])
    }

    /// A stored cover; without a size, as the service writes one it has not measured.
    static func cover(_ name: String, width: Int? = 320, height: Int? = 180) -> [String: Any] {
        [
            "url": "https://example.com/media/" + name, "width": width ?? NSNull(),
            "height": height ?? NSNull(),
        ]
    }

    /// A stored video; every optional field is `null` unless given.
    static func storedVideo(
        source: String = "youtube", id: String, availability: String? = nil, durationSeconds: Int? = nil
    ) -> [String: Any] {
        [
            "source": source, "id": id, "title": "Stored " + id, "url": "https://example.com/watch/" + id,
            "publishedAt": NSNull(), "scheduledAt": NSNull(), "durationSeconds": durationSeconds ?? NSNull(),
            "availability": availability ?? NSNull(), "translations": NSNull(), "sourceLanguage": NSNull(),
        ]
    }

    static func state(cover: [String: Any]? = nil, videos: [[String: Any]] = []) -> [String: Any] {
        ["cover": cover ?? NSNull(), "videos": videos]
    }

    static func recent(
        id: String, source: String = "youtube", publishedAt: String? = nil, origin: String = "auto",
        translations: [String: Any]? = nil, alternates: [[String: Any]] = []
    ) -> [String: Any] {
        [
            "id": id, "source": source, "title": "Recent " + id, "url": "https://example.com/watch/" + id,
            "publishedAt": publishedAt ?? NSNull(), "cover": NSNull(), "origin": origin,
            "translations": translations ?? NSNull(), "sourceLanguage": "ja", "alternates": alternates,
        ]
    }

    static func stored(
        uploads: [String: Any] = [:], recent: [[String: Any]] = [], recentTotal: Int? = nil
    ) throws -> WorksUploadsResponse {
        try decode(
            WorksUploadsResponse.self,
            [
                "updatedAt": "2026-11-07", "revision": 1, "uploads": uploads, "recent": recent,
                "recentTotal": recentTotal ?? recent.count,
            ])
    }

    static func decode<Value: Decodable>(_ type: Value.Type, _ json: Any) throws -> Value {
        let data = try JSONSerialization.data(withJSONObject: json)
        return try JSONDecoder.kanoNavi().decode(type, from: data)
    }
}
