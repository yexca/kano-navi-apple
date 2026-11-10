import Foundation

/// The app's marketing version and build number from its Info.plist.
struct AppVersion: Equatable {
    var version: String?
    var build: String?

    init(infoDictionary: [String: Any]) {
        version = infoDictionary["CFBundleShortVersionString"] as? String
        build = infoDictionary["CFBundleVersion"] as? String
    }

    static var main: AppVersion { AppVersion(infoDictionary: Bundle.main.infoDictionary ?? [:]) }

    /// `0.1.0 (1)`, or whichever part is known.
    var displayString: String {
        switch (version, build) {
        case (let version?, let build?) where version != build: "\(version) (\(build))"
        case (let version?, _): version
        case (nil, let build?): build
        case (nil, nil): "—"
        }
    }
}
