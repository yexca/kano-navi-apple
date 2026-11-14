import KanoNaviCore
import SwiftUI

/// The end of the timeline and the gallery: the date the data was checked
/// through, with an info button that folds away how the list is made and
/// the rights notice for the images.
struct JourneyFooter: View {
    let updatedAt: JapanDate

    @Environment(\.locale) private var locale
    @State private var showsNotes = false

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 6) {
            Text(.Journey.checkedThrough(JourneyDateFormat.day(updatedAt, locale: locale)))
            Button {
                showsNotes = true
            } label: {
                Label {
                    Text(.Journey.aboutNotes)
                } icon: {
                    Image(systemName: "info.circle")
                }
                .labelStyle(.iconOnly)
            }
            .accessibilityIdentifier("journey.notes")
            .popover(isPresented: $showsNotes) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(.Journey.disclaimer)
                    Text(.Journey.imageRights)
                }
                .font(.footnote)
                .foregroundStyle(.primary)
                .fixedSize(horizontal: false, vertical: true)
                .frame(idealWidth: 300)
                .padding()
                .presentationCompactAdaptation(.popover)
            }
        }
        .font(.footnote)
        .foregroundStyle(.secondary)
        .frame(maxWidth: .infinity)
        .padding()
        .padding(.bottom, 16)
    }
}
