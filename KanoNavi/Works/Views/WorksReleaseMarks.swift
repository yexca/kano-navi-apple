import KanoNaviComponents
import KanoNaviCore
import SwiftUI

/// A release's marks as a wrapping row of chips.
struct WorksReleaseMarks: View {
    let marks: [WorksReleaseMark]

    var body: some View {
        FlowLayout(spacing: 4) {
            ForEach(marks, id: \.self) { mark in
                switch mark {
                case .cancelled:
                    ComponentChip(title: .Works.cancelled, systemImage: "xmark.circle.fill", tint: .red)
                case .format(let format):
                    ComponentChip(title: WorksCodeLabels.format(format), tint: .secondary)
                case .digital:
                    ComponentChip(title: .Works.digital, systemImage: "arrow.down.circle", tint: .blue)
                case .unit(let name):
                    ComponentChip(title: .Works.unitNamed(name), systemImage: "person.2.fill", tint: .purple)
                }
            }
        }
    }
}
