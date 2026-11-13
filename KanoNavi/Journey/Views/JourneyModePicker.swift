import SwiftUI

/// The segmented switch between the timeline and the gallery.
struct JourneyModePicker: View {
    @Binding var mode: JourneyMode

    var body: some View {
        Picker(selection: $mode) {
            Text(.Journey.modeTimeline).tag(JourneyMode.timeline)
            Text(.Journey.modeGallery).tag(JourneyMode.gallery)
        } label: {
            Text(.Journey.modePicker)
        }
        .pickerStyle(.segmented)
        .padding(.horizontal)
        .padding(.bottom, 8)
    }
}
