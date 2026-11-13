import Observation

/// Whether one picture of an article can be shown, found out by loading
/// it. The reader needs to know before it draws the picture: a picture
/// that is there opens in the viewer, one that is not says so and offers
/// another try.
@Observable
final class LineBlogPictureLoad {
    /// Where the load stands.
    enum Phase: Equatable {
        /// Not loaded yet: the picture's place is held.
        case waiting
        /// The picture can be drawn.
        case loaded
        /// The server does not have the file, or it is not an image.
        case unavailable
        /// The fetch failed; trying again may work.
        case failed
    }

    private(set) var phase = Phase.waiting

    /// Loads the picture as `request` asks for it. A picture that has
    /// loaded stays loaded; the view that draws it follows later changes of
    /// its size by itself.
    func load(_ request: MediaImageRequest, with loader: MediaImageLoader) async {
        guard phase != .loaded else { return }
        phase = .waiting
        do {
            _ = try await loader.image(for: request)
            phase = .loaded
        } catch MediaImageError.unavailable {
            phase = .unavailable
        } catch is MediaImageError {
            phase = .failed
        } catch {
            // Cancelled: the picture left the screen or changed its size.
        }
    }
}
