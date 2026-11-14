import SwiftUI

/// The top of the timeline and the gallery when the Journey on screen is a
/// saved copy or a reload failed: the notice as a card, with Try Again.
struct JourneyNotice: View {
    let notice: DocumentNotice
    let reload: () async -> Void

    var body: some View {
        DocumentStatusNotice(notice: notice, reload: reload)
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(.fill.tertiary, in: .rect(cornerRadius: 12))
            .padding(.horizontal)
    }
}
