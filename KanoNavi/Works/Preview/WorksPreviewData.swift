import CoreGraphics
import Foundation
import ImageIO
import KanoNaviCore
import UniformTypeIdentifiers

/// Synthetic Works documents for previews, decoded from JSON in the API's
/// shape with the API's own decoder. Nothing here is real archive data;
/// addresses use the reserved `example.com` domain.
nonisolated enum WorksPreviewData {
    static let works = decode(WorksResponse.self, worksJSON).resolvingMedia(against: baseURL)
    static let uploadList = decode(WorksUploadListResponse.self, uploadListJSON)
    static let uploads = decode(WorksUploadsResponse.self, uploadsJSON)

    /// Answers every image with a plain colored square.
    static let imageLoader = MediaImageLoader { _ in try square() }

    private static let baseURL = URL(string: "https://example.com")!

    private static func decode<Value: Decodable>(_ type: Value.Type, _ json: String) -> Value {
        do {
            return try JSONDecoder.kanoNavi().decode(type, from: Data(json.utf8))
        } catch {
            preconditionFailure("Preview JSON does not match the model: \(error)")
        }
    }

    private static func square() throws -> Data {
        let data = NSMutableData()
        guard
            let context = CGContext(
                data: nil, width: 64, height: 64, bitsPerComponent: 8, bytesPerRow: 0,
                space: CGColorSpaceCreateDeviceRGB(), bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue),
            let destination = CGImageDestinationCreateWithData(
                data, UTType.png.identifier as CFString, 1, nil)
        else { throw MediaImageError.failed }
        context.setFillColor(red: 0.55, green: 0.62, blue: 0.86, alpha: 1)
        context.fill(CGRect(x: 0, y: 0, width: 64, height: 64))
        guard let image = context.makeImage() else { throw MediaImageError.failed }
        CGImageDestinationAddImage(destination, image, nil)
        guard CGImageDestinationFinalize(destination) else { throw MediaImageError.failed }
        return data as Data
    }

    private static let imageJSON = """
        {"url": "/media/works/preview.png", "width": 600, "height": 600, "mimeType": "image/png",
         "caption": {"ja": "ジャケット", "zh-CN": "封面", "en": "Cover"},
         "sourceUrl": "https://example.com/source", "sourceLabel": null,
         "credit": {"role": "scan", "name": "Example Scanner", "url": "https://example.com/scanner"},
         "thirdParty": true}
        """

    private static let trackJSON = """
        {"disc": 1, "discLabel": null, "no": 1, "title": "Synthetic Song",
         "credit": {"ja": "作詞: 例", "zh-CN": "作词: 例", "en": "Lyrics: Example"},
         "note": {"ja": "タイアップ曲", "zh-CN": "合作曲", "en": "Tie-in song"},
         "listen": {"niconico": "sm1", "youtube": ["abc"], "youtubeMembers": ["def"], "bilibili": "BV1"}}
        """

    private static let worksJSON = """
        {"updatedAt": "2026-11-07",
         "summary": {"personal": 2, "participation": 1, "uploads": 3, "firstYear": 2010, "lastYear": 2026},
         "personal": [
          {"id": "2020-03-04-aaaaaa", "date": "2020-03-04", "title": "Synthetic Album", "format": "album",
           "digital": false, "cancelled": false, "unit": null,
           "label": {"ja": "サンプルレコード", "zh-CN": "示例唱片", "en": "Example Records"},
           "catalog": {"ja": "EXAM-1 (初回盤); EXAM-2 (通常盤)", "zh-CN": "EXAM-1; EXAM-2", "en": "EXAM-1; EXAM-2"},
           "covers": [\(imageJSON)], "disc": null, "printedDisc": false, "cutout": null,
           "tracks": [\(trackJSON)], "discs": [],
           "editions": [
            {"name": {"ja": "初回盤", "zh-CN": "初回盘", "en": "First press"}, "date": null, "cancelled": false,
             "catalog": {"ja": "EXAM-1", "zh-CN": "EXAM-1", "en": "EXAM-1"}, "jan": "4900000000000",
             "price": {"ja": "¥3,000+税", "zh-CN": "¥3,000+税", "en": "¥3,000 + tax"},
             "format": {"ja": "CD+DVD", "zh-CN": "CD+DVD", "en": "CD+DVD"}, "packaging": null,
             "covers": [\(imageJSON)],
             "bonuses": [{"ja": "ブックレット", "zh-CN": "小册子", "en": "Booklet"}], "bonusImages": [],
             "storeBonuses": [], "stores": [], "tracks": [\(trackJSON)], "discs": [], "printedDisc": false}],
           "storeBonuses": [
            {"store": {"ja": "サンプル店", "zh-CN": "示例店", "en": "Example Store"},
             "item": {"ja": "缶バッジ", "zh-CN": "徽章", "en": "Tin badge"}, "images": []}],
           "stores": [{"item": null, "links": [
            {"platform": "apple_music", "url": "https://example.com/apple", "hiRes": false},
            {"platform": "mora", "url": "https://example.com/mora", "hiRes": true}]}]},
          {"id": "2024-06-01-bbbbbb", "date": "2024-06-01", "title": "Synthetic Single", "format": "single",
           "digital": true, "cancelled": false, "unit": "Example Unit", "label": null, "catalog": null,
           "covers": [], "disc": null, "printedDisc": false, "cutout": null, "tracks": [], "discs": [],
           "editions": [], "storeBonuses": [], "stores": []}],
         "participation": [
          {"id": "2012-08-11-cccccc", "date": "2012-08-11", "title": "Synthetic Compilation",
           "roles": ["vocal", "lyrics"], "forms": ["digital"], "unit": null, "label": "Example Circle",
           "event": "Example Market 82", "catalog": "EXC-001", "sourceUrl": "https://example.com/record",
           "cover": \(imageJSON),
           "tracks": [
            {"disc": 1, "no": 1, "title": "Opening", "credit": "Example Artist", "kano": false, "kanoCredits": []},
            {"disc": 1, "no": 2, "title": "Synthetic Duet", "credit": "Example Artist feat. Kano", "kano": true,
             "kanoCredits": ["lyrics"]}]}]}
        """

    private static let uploadListJSON = """
        {"updatedAt": "2026-11-07", "uploads": [
         {"id": "2012-01-01-u1", "date": "2012-01-01", "song": "Synthetic Cover", "originalArtist": "Example P",
          "kind": "cover", "with": "", "niconico": "sm1", "youtube": [], "youtubeMembers": [], "bilibili": null,
          "bilibiliTitle": "", "albums": ["Synthetic Album"], "tracks": []},
         {"id": "2021-05-05-u2", "date": "2021-05-05", "song": "Synthetic Original", "originalArtist": "",
          "kind": "original", "with": "Example Friend", "niconico": null, "youtube": ["abc"],
          "youtubeMembers": ["def"], "bilibili": "BV1", "bilibiliTitle": "合成原创", "albums": [], "tracks": []},
         {"id": "2021-09-09-u3", "date": "2021-09-09", "song": "Synthetic Medley", "originalArtist": "",
          "kind": "compilation", "with": "", "niconico": null, "youtube": ["ghi"], "youtubeMembers": [],
          "bilibili": null, "bilibiliTitle": "", "albums": [], "tracks": ["First Song", "Second Song"]}]}
        """

    private static let uploadsJSON = """
        {"updatedAt": "2026-11-07", "revision": 1,
         "uploads": {"2021-05-05-u2": {"cover": {"url": "https://example.com/media/u2", "width": 320, "height": 180},
          "videos": [{"source": "youtube", "id": "abc", "title": "Synthetic Original",
           "url": "https://example.com/watch/abc", "publishedAt": "2021-05-05T10:00:00Z", "scheduledAt": null,
           "durationSeconds": 245, "availability": "public", "translations": null, "sourceLanguage": "ja"}]}},
         "recent": [{"id": "new1", "source": "youtube", "title": "Synthetic New Song",
          "url": "https://example.com/watch/new1", "publishedAt": "2026-11-08T08:00:00Z", "cover": null,
          "origin": "auto", "translations": null, "sourceLanguage": "ja", "alternates": []}],
         "recentTotal": 1}
        """
}
