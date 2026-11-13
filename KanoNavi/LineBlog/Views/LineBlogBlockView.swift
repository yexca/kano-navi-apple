import KanoNaviCore
import SwiftUI

/// One block of an article.
struct LineBlogBlockView: View {
    let block: LineBlogReaderBlock
    /// The language whose translations show, or `nil` for none.
    let translation: ContentLocale?
    let pictographs: LineBlogPictographStore
    /// Opens a picture in the viewer.
    let open: (LineBlogPicture) -> Void

    var body: some View {
        switch block.content {
        case .paragraph(let paragraph):
            VStack(alignment: .leading, spacing: 6) {
                LineBlogSegmentsView(segments: paragraph.segments, pictographs: pictographs, open: open)
                let translated = paragraph.translation(in: translation)
                ForEach(translated.indices, id: \.self) { index in
                    LineBlogTranslationMark {
                        LineBlogTextView(
                            text: translated[index], style: .translation, pictographs: pictographs)
                    }
                }
            }
        case .quote(let segments):
            LineBlogSegmentsView(segments: segments, pictographs: pictographs, open: open)
                .padding(.vertical, 10)
                .padding(.horizontal, 14)
                .background(.fill.quaternary, in: .rect(cornerRadius: 10))
                .overlay(alignment: .leading) {
                    UnevenRoundedRectangle(topLeadingRadius: 10, bottomLeadingRadius: 10)
                        .fill(.secondary)
                        .frame(width: 4)
                }
                .accessibilityElement(children: .contain)
                .accessibilityLabel(Text(.LineBlog.quote))
        case .rule:
            Divider()
                .padding(.vertical, 8)
        case .video(let video):
            LineBlogVideoView(video: video)
        case .card(let card):
            LineBlogCardView(card: card)
        }
    }
}
