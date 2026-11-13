#if DEBUG
    import CoreGraphics
    import Foundation
    import ImageIO
    import KanoNaviCore
    import UniformTypeIdentifiers

    /// A synthetic article for previews: every block and inline the contract
    /// has, on the reserved `example.com` domain, with flat-color pictures
    /// drawn here in place of files.
    nonisolated enum LineBlogPreviewData {
        /// An article with a long paragraph of pictographs, links in and out
        /// of the archive, translations, figures, a quote, a rule, videos
        /// and cards.
        static let response: LineBlogPostResponse? = {
            try? JSONDecoder.kanoNavi().decode(LineBlogPostResponse.self, from: Data(json.utf8))
        }()

        /// An article whose paragraphs have no translation but whose title
        /// has an English one: the reader still offers its switch.
        static let titleOnlyResponse: LineBlogPostResponse? = {
            let article = """
                {
                  "updatedAt": "2017-03-09", "previousId": null, "nextId": null,
                  "post": {
                    "id": "1003", "published": "2017-03-10T03:00:00.000Z",
                    "title": {"ja": "題名だけ翻訳のある記事", "zh-CN": null, "en": "Only the title is translated"},
                    "url": "https://blog.example.com/archives/1003.html",
                    "archiveUrl": "https://archive.example.com/blog/1003",
                    "blocks": [
                      {"type": "paragraph", "content": [{"type": "text", "text": "本文には翻訳がありません。"}],
                       "translations": {"zh-CN": null, "en": null}}
                    ]
                  }
                }
                """
            return try? JSONDecoder.kanoNavi().decode(LineBlogPostResponse.self, from: Data(article.utf8))
        }()

        /// The article list's entries for the preview article and its
        /// neighbours.
        static let summaries: [LineBlogPostSummary] = {
            let list = """
                [
                  {"id": "1001", "published": "2017-03-04T03:00:00.000Z",
                   "title": {"ja": "合成の記事", "zh-CN": "合成文章", "en": "Synthetic article"},
                   "thumbnail": null, "commentCount": 12},
                  {"id": "1000", "published": "2017-03-01T03:00:00.000Z",
                   "title": {"ja": "ひとつ前の記事", "zh-CN": null, "en": "The article before"},
                   "thumbnail": null, "commentCount": 0},
                  {"id": "1002", "published": "2017-03-09T03:00:00.000Z",
                   "title": {"ja": "ひとつ後の記事", "zh-CN": null, "en": "The article after"},
                   "thumbnail": null, "commentCount": 3}
                ]
                """
            return (try? JSONDecoder.kanoNavi().decode([LineBlogPostSummary].self, from: Data(list.utf8)))
                ?? []
        }()

        /// A loader that answers every file with a flat-color picture; a
        /// name containing `missing` is a file the server does not have,
        /// and one containing `failed` a fetch that fails.
        static let loader = MediaImageLoader { url in
            if url.lastPathComponent.contains("missing") {
                throw MediaImageError.unavailable
            }
            if url.lastPathComponent.contains("failed") {
                throw MediaImageError.failed
            }
            return picture(seed: url.lastPathComponent)
        }

        private static func picture(seed: String) -> Data {
            let hue = seed.unicodeScalars.reduce(0) { ($0 + Int($1.value)) % 360 }
            let side = 96
            guard
                let context = CGContext(
                    data: nil, width: side, height: side, bitsPerComponent: 8, bytesPerRow: 0,
                    space: CGColorSpaceCreateDeviceRGB(),
                    bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)
            else { return Data() }
            let red = 0.5 + 0.4 * cos(Double(hue) * .pi / 180)
            let green = 0.5 + 0.4 * cos(Double(hue + 120) * .pi / 180)
            let blue = 0.5 + 0.4 * cos(Double(hue + 240) * .pi / 180)
            context.setFillColor(red: red, green: green, blue: blue, alpha: 1)
            context.fillEllipse(in: CGRect(x: 4, y: 4, width: side - 8, height: side - 8))
            let data = NSMutableData()
            guard let image = context.makeImage(),
                let destination = CGImageDestinationCreateWithData(
                    data, UTType.png.identifier as CFString, 1, nil)
            else { return Data() }
            CGImageDestinationAddImage(destination, image, nil)
            CGImageDestinationFinalize(destination)
            return data as Data
        }

        private static func pictograph(_ name: String) -> String {
            """
            {"type": "image", "emoji": true, "alt": null, "href": null, "sourceUrl": null, "remoteUrl": null,
             "recovery": null,
             "image": {"url": "\(media)\(name).png", "width": 20, "height": 20, "mimeType": "image/png"}}
            """
        }

        private static func image(
            _ name: String?, width: Int = 640, height: Int = 480, alt: String? = nil, recovery: String? = nil,
            remote: String? = nil
        ) -> String {
            let file =
                name.map {
                    """
                    {"url": "\(media)\($0).jpg", "width": \(width), "height": \(height), "mimeType": "image/jpeg"}
                    """
                } ?? "null"
            return """
                {"type": "image", "emoji": false, "alt": \(quoted(alt)), "href": null,
                 "sourceUrl": "https://archive.example.com/picture", "remoteUrl": \(quoted(remote)),
                 "recovery": \(quoted(recovery)), "image": \(file)}
                """
        }

        private static func quoted(_ text: String?) -> String {
            text.map { "\"\($0)\"" } ?? "null"
        }

        private static let media = "https://example.com/media/lineblog/"

        /// Twelve sentences, each ending in a pictograph.
        private static let longParagraph: String = {
            let sentence = "これは合成の文章です。絵文字が文字の大きさで行の中に並び、長い段落でも一度に組まれます"
            return (0..<12).map { index in
                """
                {"type": "text", "text": "\(sentence)"}, \(pictograph("glyph\(index % 4)"))
                """
            }.joined(separator: ", ")
        }()

        private static let json = """
            {
              "updatedAt": "2017-03-09", "previousId": "1000", "nextId": "1002",
              "post": {
                "id": "1001", "published": "2017-03-04T03:00:00.000Z",
                "title": {"ja": "合成の記事", "zh-CN": "合成文章", "en": "Synthetic article"},
                "url": "https://blog.example.com/archives/1001.html",
                "archiveUrl": "https://archive.example.com/blog/1001",
                "blocks": [
                  {"type": "paragraph", "content": [\(longParagraph)], "translations": null},
                  {"type": "paragraph",
                   "content": [
                     {"type": "text", "text": "前回の記事は"},
                     {"type": "link", "href": "https://blog.example.com/archives/1000.html", "articleId": "1000",
                      "content": [{"type": "text", "text": "こちら"}]},
                     {"type": "text", "text": "、お店のページは"},
                     {"type": "link", "href": "https://shop.example.com/item", "articleId": null,
                      "content": [{"type": "text", "text": "こちら"}, \(pictograph("glyph1"))]},
                     {"type": "text", "text": "です。絵文字だけのリンクは"},
                     {"type": "link", "href": "https://blog.example.com/archives/1002.html", "articleId": "1002",
                      "content": [\(pictograph("glyph2"))]},
                     {"type": "text", "text": "です。\\n二行目です。"}
                   ],
                   "translations": {
                     "zh-CN": [[{"type": "text", "text": "上一篇文章在这里，商店页面在这里。\\n这是第二行。"}]],
                     "en": [[
                       {"type": "text", "text": "The previous article is "},
                       {"type": "link", "href": "https://blog.example.com/archives/1000.html", "articleId": "1000",
                        "content": [{"type": "text", "text": "here"}]},
                       {"type": "text", "text": ", and the shop page is here.\\nThis is the second line."}
                     ]]
                   }},
                  {"type": "paragraph", "content": [\(image("photo1", alt: "合成の写真", recovery: "stand-in"))],
                   "translations": null},
                  {"type": "paragraph",
                   "content": [
                     \(image("photo2", recovery: "tweet")), \(image("photo3", recovery: "tweet")),
                     \(image("failed", recovery: "tweet")), \(image("missing", recovery: "tweet"))
                   ],
                   "translations": null},
                  {"type": "paragraph",
                   "content": [\(image(nil, alt: "告知の画像", remote: "https://img.example.com/lost.jpg"))],
                   "translations": null},
                  {"type": "quote", "content": [{"type": "text", "text": "これは引用です。\\n二行目も引用です。"}]},
                  {"type": "rule"},
                  {"type": "youtube", "videoId": "synthetic01", "watchUrl": "https://video.example.com/watch?v=1",
                   "video": {"url": "\(media)copy.mp4", "width": null, "height": null, "mimeType": "video/mp4"},
                   "cover": {"url": "\(media)cover1.jpg", "width": 480, "height": 360, "mimeType": "image/jpeg"},
                   "coverSourceUrl": null, "archiveUrl": "https://archive.example.com/watch?v=1"},
                  {"type": "youtube", "videoId": "synthetic02", "watchUrl": "https://video.example.com/watch?v=2",
                   "video": null,
                   "cover": {"url": "\(media)cover2.jpg", "width": 480, "height": 360, "mimeType": "image/jpeg"},
                   "coverSourceUrl": null, "archiveUrl": null},
                  {"type": "video",
                   "video": {"url": "\(media)clip.mp4", "width": null, "height": null, "mimeType": "video/mp4"}},
                  {"type": "poll", "question": "a block type this app does not know"},
                  {"type": "card", "title": "ひとつ前の記事", "url": "https://blog.example.com/archives/1000.html",
                   "articleId": "1000", "archiveUrl": null, "description": "アーカイブ内の記事へのカードです。",
                   "image": null},
                  {"type": "card", "title": "合成のお店の商品ページ", "url": "https://shop.example.com/item",
                   "articleId": null, "archiveUrl": "https://archive.example.com/shop",
                   "description": "外部のページへのカードです。説明文は二行までで切れます。",
                   "image": \(image("card", width: 200, height: 200))}
                ]
              }
            }
            """
    }
#endif
