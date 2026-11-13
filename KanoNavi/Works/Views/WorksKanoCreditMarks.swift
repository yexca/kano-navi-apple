import KanoNaviComponents
import KanoNaviCore
import SwiftUI

/// Marks a track Kano took part in, with her further credits on it.
struct WorksKanoCreditMarks: View {
    let credits: [WorksKanoCredit]
    var showsKanoMark = true

    var body: some View {
        FlowLayout(spacing: 4) {
            if showsKanoMark {
                ComponentChip(title: .Works.kanoTrack, systemImage: "music.microphone", tint: .pink)
            }
            ForEach(credits, id: \.self) { credit in
                ComponentChip(title: WorksCodeLabels.kanoCredit(credit), tint: .pink)
            }
        }
    }
}
