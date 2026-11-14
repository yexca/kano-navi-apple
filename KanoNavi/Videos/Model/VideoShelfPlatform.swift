import Foundation
import KanoNaviComponents
import KanoNaviCore

/// A platform the video shelf can be narrowed to.
enum VideoShelfPlatform: String, CaseIterable, Identifiable {
    case youtube
    case bilibili

    var id: String { rawValue }

    var platform: EventPlatform {
        switch self {
        case .youtube: .youtube
        case .bilibili: .bilibili
        }
    }

    var logo: PlatformLogo {
        switch self {
        case .youtube: .youtube
        case .bilibili: .bilibili
        }
    }

    var name: LocalizedStringResource {
        DisplayCodeLabels.platform(platform)
    }
}
