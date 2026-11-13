import KanoNaviCore
import SwiftUI

/// The end of the timeline and the gallery: how the list is made, the
/// rights notice for the images and the date the data was checked through.
struct JourneyFooter: View {
    let updatedAt: JapanDate

    @Environment(\.locale) private var locale

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(.Journey.disclaimer)
            Text(.Journey.imageRights)
            Text(.Journey.checkedThrough(JourneyDateFormat.day(updatedAt, locale: locale)))
        }
        .font(.footnote)
        .foregroundStyle(.secondary)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .padding(.bottom, 16)
    }
}
