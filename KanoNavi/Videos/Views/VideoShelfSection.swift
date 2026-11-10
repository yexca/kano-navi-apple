import SwiftUI

/// One group of the shelf as a list section, left out when it is empty.
struct VideoShelfSection: View {
    let title: LocalizedStringResource
    let cards: [VideoCard]

    var body: some View {
        if cards.isEmpty == false {
            Section {
                ForEach(cards) { card in
                    VideoRow(card: card)
                }
            } header: {
                Text(title)
            }
        }
    }
}
