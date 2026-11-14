import SwiftUI

#if os(iOS)
    import UIKit
#else
    import AppKit
#endif

/// A color's sRGB components as the app draws it in an appearance.
enum ColorComponents {
    /// The red, green and blue of `color` in `scheme`, from 0 to 1.
    @MainActor
    static func rgb(_ color: Color, in scheme: ColorScheme) -> [Double] {
        var environment = EnvironmentValues()
        environment.colorScheme = scheme
        let resolved = color.resolve(in: environment)
        return [resolved.red, resolved.green, resolved.blue].map(Double.init)
    }

    /// The plain background screens draw text on: the system background on
    /// iOS, the text background on macOS.
    static var screenBackground: Color {
        #if os(iOS)
            Color(uiColor: .systemBackground)
        #else
            Color(nsColor: .textBackgroundColor)
        #endif
    }
}
