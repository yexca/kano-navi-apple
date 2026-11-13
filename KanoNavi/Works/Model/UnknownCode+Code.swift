import KanoNaviCore

extension UnknownCode {
    /// The value of a code as the API writes it; a code the app does not
    /// know becomes the type's `unknown` case, as it does when decoding.
    nonisolated init(code: String) {
        self = Self.knownValues[code] ?? Self.unknownValue(code)
    }
}
