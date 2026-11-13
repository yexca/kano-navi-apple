import SwiftUI

/// The toolbar menu that scrolls the timeline: Latest first, then each year
/// shown, oldest first.
struct JourneyYearMenu: View {
    let years: [Int]
    let jump: (Int) -> Void

    var body: some View {
        Menu {
            if let latest = years.last {
                Button(.Journey.jumpLatest, systemImage: "arrow.down.to.line") {
                    jump(latest)
                }
                .accessibilityIdentifier("journey.jump.latest")
                Divider()
            }
            ForEach(years, id: \.self) { year in
                Button {
                    jump(year)
                } label: {
                    Text(verbatim: String(year))
                }
                .accessibilityIdentifier("journey.jump.\(year)")
            }
        } label: {
            Label {
                Text(.Journey.jumpToYear)
            } icon: {
                Image(systemName: "calendar")
            }
        }
        .disabled(years.isEmpty)
        .accessibilityIdentifier("journey.yearMenu")
    }
}
