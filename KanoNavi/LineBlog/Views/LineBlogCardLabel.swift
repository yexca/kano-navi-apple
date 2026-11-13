import SwiftUI

/// The face of a link card: its picture, title, summary and where it
/// leads.
struct LineBlogCardLabel: View {
    let card: LineBlogLinkCard

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @ScaledMetric(relativeTo: .subheadline) private var imageSide: CGFloat = 72

    var body: some View {
        let layout =
            dynamicTypeSize.isAccessibilitySize
            ? AnyLayout(VStackLayout(alignment: .leading, spacing: 8))
            : AnyLayout(HStackLayout(alignment: .top, spacing: 12))
        layout {
            if let image = card.image {
                MediaImage(decorative: image, contentMode: .fill)
                    .frame(width: min(imageSide, 96), height: min(imageSide, 96))
                    .clipShape(.rect(cornerRadius: 6))
            }
            VStack(alignment: .leading, spacing: 4) {
                Text(verbatim: card.title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.primary)
                    .lineLimit(3)
                if let description = card.description {
                    Text(verbatim: description)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }
                destination
                    .font(.caption)
                    .foregroundStyle(.tint)
            }
            .multilineTextAlignment(.leading)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.fill.quaternary, in: .rect(cornerRadius: 12))
        .contentShape(.rect(cornerRadius: 12))
        .accessibilityElement(children: .combine)
    }

    @ViewBuilder private var destination: some View {
        switch card.target {
        case .article?:
            Label {
                Text(.LineBlog.cardInArchive)
            } icon: {
                Image(systemName: "book.closed")
            }
        case .outside?:
            if let host = card.host {
                Label {
                    Text(verbatim: host)
                } icon: {
                    Image(systemName: "arrow.up.right")
                }
            }
        case nil:
            EmptyView()
        }
    }
}
