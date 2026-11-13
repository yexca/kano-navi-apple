import Foundation
import KanoNaviCore

/// A comment's rating as it is drawn and read: the glyphs of the old comment
/// form, the value in figures beside them, and a sentence for VoiceOver.
nonisolated struct LineBlogRatingDisplay: Equatable, Sendable {
    /// The highest rating.
    static let scale = 5

    /// The form's faces, from 1 (worst) to 5 (best).
    private static let faces = ["😣", "😟", "😐", "🙂", "😊"]

    let icon: LineBlogRatingIcon
    let value: Int

    /// `nil` for a value outside 1 to 5, which is not drawn.
    init?(_ rating: LineBlogRating) {
        guard (1...Self.scale).contains(rating.value) else { return nil }
        icon = rating.icon
        value = rating.value
    }

    /// The glyphs alone: filled and empty stars, one face, or nothing for a
    /// kind of rating this app does not know.
    var glyphs: String {
        switch icon {
        case .star:
            String(repeating: "★", count: value) + String(repeating: "☆", count: Self.scale - value)
        case .face: Self.faces[value - 1]
        case .unknown: ""
        }
    }

    /// The value in figures, such as `4/5`, drawn beside the glyphs so the
    /// rating does not rest on them alone.
    var figures: String { "\(value)/\(Self.scale)" }

    /// The rating in words.
    var label: LocalizedStringResource {
        switch icon {
        case .star: .LineBlog.ratingStars(value, Self.scale)
        case .face: .LineBlog.ratingFaces(value, Self.scale)
        case .unknown: .LineBlog.ratingPlain(value, Self.scale)
        }
    }
}
