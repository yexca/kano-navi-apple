import KanoNaviCore
import SwiftUI

/// A platform's generic symbol and its name, such as YouTube or Bilibili.
///
/// The marks are SF Symbols, not the platforms' logos. With `showsName`
/// set to `false` only the symbol is drawn, and VoiceOver still reads the
/// name. Safe in widgets.
public struct PlatformMark: View {
    private let platform: EventPlatform
    private let showsName: Bool

    /// Creates a mark for a platform code from the API.
    public init(platform: EventPlatform, showsName: Bool = true) {
        self.platform = platform
        self.showsName = showsName
    }

    public var body: some View {
        let label = Label {
            Text(Self.name(for: platform))
        } icon: {
            Image(systemName: Self.systemImage(for: platform))
        }
        if showsName {
            label.labelStyle(.titleAndIcon)
        } else {
            label.labelStyle(.iconOnly)
        }
    }

    /// The platform's name from the core label table. `other` is a web page
    /// outside the listed platforms, such as a shop or a post.
    static func name(for platform: EventPlatform) -> LocalizedStringResource {
        DisplayCodeLabels.platform(platform)
    }

    /// The symbol drawn for a platform.
    static func systemImage(for platform: EventPlatform) -> String {
        switch platform {
        case .youtube: "play.rectangle.fill"
        case .bilibili: "tv.fill"
        case .other, .unknown: "link"
        }
    }
}

#Preview {
    VStack(alignment: .leading) {
        PlatformMark(platform: .youtube)
        PlatformMark(platform: .bilibili)
        PlatformMark(platform: .other, showsName: false)
    }
}
