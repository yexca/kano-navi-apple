import KanoNaviCore
import SwiftUI

extension ServiceServer {
    /// The localized name of a built-in server, or the name the person gave
    /// a server they added, shown as typed.
    var nameText: Text {
        switch builtIn {
        case .japan: Text(.More.serverJapan)
        case .mainlandChina: Text(.More.serverMainlandChina)
        case nil: Text(verbatim: name)
        }
    }
}
