import SwiftUI

/// What VoiceOver calls a picture of an article.
enum LineBlogPictureLabel {
    /// The picture's alternative text, or "Photo" without one.
    static func text(for picture: LineBlogPicture) -> Text {
        text(alt: picture.alt)
    }

    static func text(alt: String?) -> Text {
        if let alt, alt.isEmpty == false {
            Text(verbatim: alt)
        } else {
            Text(.LineBlog.photo)
        }
    }
}
