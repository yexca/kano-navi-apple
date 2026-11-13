import SwiftUI

/// The toolbar menu that chooses whether a Works list shows its newest or
/// its oldest items first.
struct WorksOrderMenu: View {
    @Binding var order: WorksOrder

    var body: some View {
        Menu {
            Picker(selection: $order) {
                Text(.Works.orderNewest).tag(WorksOrder.newestFirst)
                Text(.Works.orderOldest).tag(WorksOrder.oldestFirst)
            } label: {
                Text(.Works.order)
            }
        } label: {
            Label {
                Text(.Works.order)
            } icon: {
                Image(systemName: "arrow.up.arrow.down")
            }
        }
    }
}
