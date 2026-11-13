import SwiftUI

/// Lays out one track: its number in a column beside its title and
/// details. At accessibility text sizes only the title sits beside the
/// number and the details take the row's width below, so credits wrap in
/// whole words.
struct WorksTrackLayout<Title: View, Details: View>: View {
    let number: Int
    @ViewBuilder let title: Title
    @ViewBuilder let details: Details

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            if dynamicTypeSize.isAccessibilitySize {
                HStack(alignment: .firstTextBaseline, spacing: 8) {
                    WorksTrackNumber(number: number, alignsInColumn: false)
                    title
                }
                details
            } else {
                HStack(alignment: .firstTextBaseline, spacing: 10) {
                    WorksTrackNumber(number: number)
                    VStack(alignment: .leading, spacing: 4) {
                        title
                        details
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
