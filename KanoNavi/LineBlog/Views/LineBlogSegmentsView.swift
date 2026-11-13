import SwiftUI

/// The pieces of a paragraph or quote in reading order: running text and
/// the rows of pictures between it.
struct LineBlogSegmentsView: View {
    let segments: [LineBlogSegment]
    let pictographs: LineBlogPictographStore
    let open: (LineBlogPicture) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            ForEach(segments.indices, id: \.self) { index in
                switch segments[index] {
                case .text(let text):
                    LineBlogTextView(text: text, style: .original, pictographs: pictographs)
                case .figures(let figures):
                    LineBlogFigureRow(figures: figures, open: open)
                }
            }
        }
    }
}
