import KanoNaviComponents
import KanoNaviCore
import SwiftUI

/// One streaming or download store page; it opens in the browser.
struct WorksStoreLinkRow: View {
    let link: WorksStoreLink

    var body: some View {
        Link(destination: link.url) {
            HStack(spacing: 8) {
                Text(WorksCodeLabels.storePlatform(link.platform))
                if link.hiRes {
                    ComponentChip(title: .Works.hiRes, tint: .orange)
                }
                Spacer(minLength: 8)
                Image(systemName: "arrow.up.right")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(.tertiary)
                    .accessibilityHidden(true)
            }
        }
        .accessibilityHint(Text(verbatim: WorksImageProvenance.displayHost(of: link.url)))
    }
}
