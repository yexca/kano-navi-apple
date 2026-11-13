import KanoNaviCore
import SwiftUI

/// Who scanned or gave a release cover, linking their page when the data
/// names one.
struct JourneyCoverCredit: View {
    let credit: WorksImageCredit?

    var body: some View {
        if let text = JourneyLabels.coverCredit(credit) {
            if let url = credit?.url {
                Link(destination: url) {
                    Text(text)
                }
                .font(.footnote)
            } else {
                Text(text)
                    .font(.footnote)
            }
        }
    }
}
