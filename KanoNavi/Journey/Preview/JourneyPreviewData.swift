#if DEBUG
    import Foundation
    import KanoNaviCore

    /// A small synthetic Journey for previews: two identities, three
    /// milestones and placeholder images on `example.com`.
    enum JourneyPreviewData {
        static let journey: JourneyResponse = {
            let data = Data(json.utf8)
            do {
                return try JSONDecoder.kanoNavi().decode(JourneyResponse.self, from: data)
            } catch {
                fatalError("Preview Journey does not decode: \(error)")
            }
        }()

        private static func media(_ id: String, branch: String, category: String = "artwork") -> String {
            """
            {"origin": "fixed", "id": "\(id)", "url": "https://example.com/media/journey/\(id).jpg",
             "width": 800, "height": 1200, "mimeType": "image/jpeg", "branches": ["\(branch)"],
             "category": "\(category)", "title": {"ja": "画像 \(id)", "zh-CN": "图片 \(id)", "en": "Image \(id)"},
             "date": "2020-04-01", "dateKind": "post", "sourceKind": "artist", "note": "artwork",
             "focus": "50% 0%", "credit": null, "creator": "Example Artist", "frameTime": null,
             "sourcePage": "https://example.com/post/\(id)", "sourceUrl": "https://example.com/file/\(id).jpg",
             "originalStream": null, "releaseId": null, "cancelled": null, "cover": null}
            """
        }

        private static let json = """
            {"updatedAt": "2026-11-07",
             "branches": [
              {"id": "singer", "tone": "honey", "since": "2010",
               "label": {"ja": "歌手", "zh-CN": "歌手", "en": "Singer"}, "portrait": \(media("p1", branch: "singer"))},
              {"id": "vtuber", "tone": "berry", "since": "2021",
               "label": {"ja": "バーチャル", "zh-CN": "虚拟", "en": "Virtual"}, "portrait": null}
             ],
             "milestones": [
              {"id": "m1", "date": "2010", "datePrecision": "year", "dateEnd": null, "dateNote": null,
               "branch": "singer", "kind": "start", "highlight": true,
               "title": {"ja": "はじまり", "zh-CN": "起点", "en": "Where it began"},
               "detail": {"ja": null, "zh-CN": null, "en": "An example milestone at year precision."},
               "sourceUrl": "https://example.com/profile", "links": [], "releaseId": null, "media": []},
              {"id": "m2", "date": "2017-12-29", "datePrecision": "day", "dateEnd": null, "dateNote": "EX1",
               "branch": "singer", "kind": "release", "highlight": false,
               "title": {"ja": null, "zh-CN": null, "en": "An example release"},
               "detail": null, "sourceUrl": null,
               "links": [{"url": "https://example.com/notice", "label": "cancelledRelease"}],
               "releaseId": "2017-12-29-abc", "media": [\(media("a1", branch: "singer")), \(media("a2", branch: "singer", category: "goods"))]},
              {"id": "m3", "date": "2024-06-25", "datePrecision": "day", "dateEnd": "2024-09-30", "dateNote": null,
               "branch": "vtuber", "kind": "collab", "highlight": false,
               "title": {"ja": "コラボ", "zh-CN": "合作", "en": "An example collaboration"},
               "detail": {"ja": null, "zh-CN": null, "en": "A milestone with a date range."},
               "sourceUrl": "https://example.com/collab", "links": [], "releaseId": null,
               "media": [\(media("b1", branch: "vtuber")), \(media("b2", branch: "vtuber")), \(media("b3", branch: "vtuber")), \(media("b4", branch: "vtuber"))]}
             ],
             "galleryOnly": [\(media("g1", branch: "vtuber", category: "model"))]}
            """
    }
#endif
