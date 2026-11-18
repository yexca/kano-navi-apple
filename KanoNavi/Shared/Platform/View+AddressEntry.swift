import SwiftUI

extension View {
    /// Sets a text field up for a web address: no autocorrection or
    /// capitalization, and on iOS the URL keyboard.
    func addressEntry() -> some View {
        #if os(iOS)
            textContentType(.URL)
                .keyboardType(.URL)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
        #else
            textContentType(.URL)
                .autocorrectionDisabled()
        #endif
    }

    /// Gives a sheet's form a usable width on macOS, where a sheet takes its
    /// content's size. An iOS sheet fills its own frame.
    func sheetFormWidth() -> some View {
        #if os(iOS)
            self
        #else
            frame(width: 420)
        #endif
    }
}
