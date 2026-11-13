import SwiftUI

/// One picture of a row: an archived picture, which opens in the viewer
/// once it has loaded, or the box for a picture the archive never captured.
struct LineBlogFigureView: View {
    let figure: LineBlogFigure
    /// A square thumbnail in a grid, instead of the whole picture.
    let isThumbnail: Bool
    let open: (LineBlogPicture) -> Void

    /// The tallest a single picture is drawn, so a portrait photo does not
    /// take more than a screen.
    private static let maximumHeight: CGFloat = 520

    var body: some View {
        switch figure {
        case .picture(let picture):
            LineBlogFigurePicture(picture: picture, isThumbnail: isThumbnail, open: open)
                .frame(maxWidth: isThumbnail ? .infinity : maximumWidth(of: picture))
        case .uncaptured(let picture):
            LineBlogUncapturedPictureView(picture: picture)
        }
    }

    /// A picture is no wider than the blog showed it and no taller than
    /// `maximumHeight`; one of unknown size takes the width it is given.
    private func maximumWidth(of picture: LineBlogPicture) -> CGFloat {
        guard let size = picture.source.pixelSize else { return .infinity }
        return min(size.width, Self.maximumHeight * size.width / size.height)
    }
}
