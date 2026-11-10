import KanoNaviComponents
import KanoNaviCore
import SwiftUI

/// Who wrote a post: `@handle` on X, or the Bilibili mark and name.
struct PostAccountName: View {
    let account: PostAccount

    var body: some View {
        switch account {
        case .x(let handle):
            Text(verbatim: "@" + handle)
        case .bilibili:
            PlatformMark(platform: .bilibili)
        case .unnamedX:
            Text(.Posts.sourceX)
        }
    }
}
