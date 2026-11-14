import KanoNaviCore
import SwiftUI

/// Opens an upload's watch page in the browser when it has one; the app
/// never loads the page. Without one the content shows as it is.
struct WorksUploadWatchButton<Label: View>: View {
    let card: WorksUploadCard
    @ViewBuilder let label: Label

    @Environment(\.openURL) private var openURL

    var body: some View {
        if let watch = card.watch {
            Button {
                openURL(watch.url)
            } label: {
                label
            }
            .accessibilityHint(hint(for: watch))
        } else {
            label
        }
    }

    private func hint(for watch: WorksUploadCard.WatchPage) -> Text {
        guard let platform = watch.platform else { return Text(.Works.watchHintBrowser) }
        return Text(.Works.watchHint(String(localized: WorksCodeLabels.platform(platform))))
    }
}
