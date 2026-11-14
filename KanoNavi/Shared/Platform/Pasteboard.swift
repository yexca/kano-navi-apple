#if os(iOS)
    import UIKit
#else
    import AppKit
#endif

/// The system's general pasteboard.
enum Pasteboard {
    /// Replaces the pasteboard's contents with `url`.
    static func copy(_ url: URL) {
        #if os(iOS)
            UIPasteboard.general.url = url
        #else
            let pasteboard = NSPasteboard.general
            pasteboard.clearContents()
            pasteboard.writeObjects([url as NSURL])
        #endif
    }
}
