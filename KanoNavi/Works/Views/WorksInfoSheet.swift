import KanoNaviCore
import SwiftUI

/// What the Works entry folds behind its info button: how current the
/// collection is, and whose the covers and works are.
struct WorksInfoSheet: View {
    let updatedAt: JapanDate

    @Environment(\.locale) private var locale
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                Section {
                    LabeledContent {
                        Text(verbatim: WorksDateFormat.date(updatedAt, locale: locale))
                            .monospacedDigit()
                    } label: {
                        Text(.Works.coveredThrough)
                    }
                } footer: {
                    Text(.Works.disclaimer)
                }
            }
            .navigationTitle(.Works.info)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(role: .close) {
                        dismiss()
                    }
                }
            }
        }
        .presentationDetents([.medium, .large])
    }
}

#Preview {
    Color.clear
        .sheet(isPresented: .constant(true)) {
            WorksInfoSheet(updatedAt: WorksPreviewData.works.updatedAt)
        }
}
