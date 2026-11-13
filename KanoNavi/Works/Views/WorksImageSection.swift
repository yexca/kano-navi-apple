import KanoNaviCore
import SwiftUI

/// A titled list section holding a strip of images; nothing when there are
/// no images.
struct WorksImageSection: View {
    let title: LocalizedStringResource
    let images: [WorksImage]
    let open: (WorksImage) -> Void

    var body: some View {
        if images.isEmpty == false {
            Section {
                WorksImageStrip(images: images, fallbackTitle: String(localized: title), open: open)
            } header: {
                Text(title)
            }
        }
    }
}
