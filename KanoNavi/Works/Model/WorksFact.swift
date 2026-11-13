import KanoNaviCore

/// One named fact of a release, edition or participation work, such as its
/// label or price.
nonisolated struct WorksFact: Equatable, Identifiable, Sendable {
    /// What the fact is; the detail screens word it.
    enum Kind: String, Sendable {
        case label
        case catalog
        case price
        case format
        case packaging
        case released
        case jan
        case event
    }

    /// The fact as the API gives it.
    enum Value: Equatable, Sendable {
        /// Wording the service rendered in each language.
        case localized(LocalizedText)
        /// Text as the record writes it.
        case plain(String)
        case date(JapanDate)
    }

    let kind: Kind
    let value: Value

    var id: Kind { kind }

    /// A fact for localized wording, or `nil` when no language has any.
    static func localized(_ kind: Kind, _ text: LocalizedText?) -> WorksFact? {
        guard let text, text.isEmpty == false else { return nil }
        return WorksFact(kind: kind, value: .localized(text))
    }

    /// A fact for text as written, or `nil` when it is missing or empty.
    static func plain(_ kind: Kind, _ text: String?) -> WorksFact? {
        guard let text, text.isEmpty == false else { return nil }
        return WorksFact(kind: kind, value: .plain(text))
    }
}
