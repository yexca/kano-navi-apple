import SwiftUI

/// An entry's title, struck through when the event is cancelled.
struct EntryTitle: View {
    let item: WidgetItem
    var lineLimit = 1

    var body: some View {
        Text(item.title)
            .strikethrough(item.isCancelled)
            .foregroundStyle(item.isCancelled ? Color.secondary : Color.primary)
            .lineLimit(lineLimit)
    }
}
