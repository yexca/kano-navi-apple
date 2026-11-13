import SwiftUI

extension EnvironmentValues {
    /// The loader `MediaImage` and the image viewer fetch with: the app's
    /// shared one unless a test or preview sets another.
    @Entry var mediaImageLoader: MediaImageLoader = .shared
}
