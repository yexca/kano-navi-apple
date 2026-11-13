import SwiftUI

/// The page a record follows; it opens in the browser.
struct WorksSourceLinkRow: View {
    let url: URL

    var body: some View {
        Link(destination: url) {
            Label {
                Text(.Works.recordSource(WorksImageProvenance.displayHost(of: url)))
            } icon: {
                Image(systemName: "arrow.up.right.square")
            }
        }
    }
}
