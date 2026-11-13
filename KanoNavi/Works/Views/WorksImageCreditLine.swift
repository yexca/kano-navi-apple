import KanoNaviCore
import SwiftUI

/// The credit of a Works image; it links to the contributor's page when
/// the record gives one.
struct WorksImageCreditLine: View {
    let credit: WorksImageCredit

    var body: some View {
        ZStack(alignment: .leading) {
            if let url = credit.url {
                Link(destination: url) {
                    label
                }
            } else {
                label
                    .foregroundStyle(.secondary)
            }
        }
        .font(.subheadline)
    }

    private var label: some View {
        Label {
            Text(WorksCodeLabels.imageCredit(credit))
        } icon: {
            Image(systemName: credit.role == .photo ? "camera" : "scanner")
        }
    }
}
