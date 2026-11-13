import KanoNaviCore
import SwiftUI

/// A named fact as a row: its name small above its value, so long catalog
/// numbers and label names wrap at any text size.
struct WorksFactRow: View {
    let fact: WorksFact

    @Environment(\.locale) private var locale

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(Self.title(for: fact.kind))
                .font(.footnote)
                .foregroundStyle(.secondary)
            value
                .textSelection(.enabled)
        }
        .accessibilityElement(children: .combine)
    }

    @ViewBuilder
    private var value: some View {
        switch fact.value {
        case .localized(let text): WorksText(text)
        case .plain(let text): Text(verbatim: text)
        case .date(let date): Text(verbatim: WorksDateFormat.date(date, locale: locale))
        }
    }

    /// The name of a fact.
    nonisolated static func title(for kind: WorksFact.Kind) -> LocalizedStringResource {
        switch kind {
        case .label: .Works.factLabel
        case .catalog: .Works.factCatalog
        case .price: .Works.factPrice
        case .format: .Works.factFormat
        case .packaging: .Works.factPackaging
        case .released: .Works.factReleased
        case .jan: .Works.factJan
        case .event: .Works.factEvent
        }
    }
}
