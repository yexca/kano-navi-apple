import SwiftUI

/// The toolbar's segmented switch between the timeline and the gallery, one
/// symbol per mode. VoiceOver reads each mode's name.
struct JourneyModePicker: View {
    @Binding var mode: JourneyMode

    var body: some View {
        Picker(selection: $mode) {
            Label {
                Text(.Journey.modeTimeline)
            } icon: {
                Image(systemName: "list.bullet")
            }
            .tag(JourneyMode.timeline)
            .accessibilityIdentifier("journey.mode.timeline")
            Label {
                Text(.Journey.modeGallery)
            } icon: {
                Image(systemName: "square.grid.3x3")
            }
            .tag(JourneyMode.gallery)
            .accessibilityIdentifier("journey.mode.gallery")
        } label: {
            Text(.Journey.modePicker)
        }
        .pickerStyle(.segmented)
        .labelStyle(.iconOnly)
        .fixedSize()
        .accessibilityIdentifier("journey.mode")
    }
}
