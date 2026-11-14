import SwiftUI

extension EnvironmentValues {
    /// The loader `MediaImage` and the image viewer fetch with: the app's
    /// shared one unless a test or preview sets another.
    @Entry var mediaImageLoader: MediaImageLoader = .shared

    /// Whether a `MediaImage` decodes a file the disk cache holds as soon as
    /// it has a size, on the main actor, so the image is there on the first
    /// frame instead of fading in. For the few images at the top of a screen
    /// shown at launch; a long list leaves it off and loads in the
    /// background.
    @Entry var mediaImageDecodesCachedFilesAtOnce = false
}
