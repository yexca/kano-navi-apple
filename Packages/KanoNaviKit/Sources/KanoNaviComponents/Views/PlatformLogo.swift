import KanoNaviCore
import SwiftUI

/// A platform's monochrome logo.
///
/// Each logo is a custom symbol in this package's asset catalog, so it tints
/// with the text around it and scales with Dynamic Type like an SF Symbol in
/// a `Label`. Safe in widgets.
nonisolated public enum PlatformLogo: String, CaseIterable, Sendable {
    case youtube
    case x
    case bilibili

    /// The logo of a platform code from the API, or `nil` for a platform
    /// without one, such as `other`.
    public init?(_ platform: EventPlatform) {
        switch platform {
        case .youtube: self = .youtube
        case .bilibili: self = .bilibili
        case .other, .unknown: return nil
        }
    }

    /// The logo of a Works upload's platform, or `nil` for niconico.
    public init?(_ platform: VideoPlatform) {
        switch platform {
        case .youtube: self = .youtube
        case .bilibili: self = .bilibili
        case .niconico: return nil
        }
    }

    /// The logo as a template symbol.
    public var image: Image {
        Image(symbolName, bundle: #bundle)
    }

    /// The custom symbol's name in the asset catalog.
    var symbolName: String {
        "logo." + rawValue
    }
}
