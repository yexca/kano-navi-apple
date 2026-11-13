import KanoNaviCore
import SwiftUI

extension JourneyMedia {
    /// The image file for `MediaImage` and the viewer.
    var imageSource: MediaImageSource {
        MediaImageSource(url: url, width: width, height: height)
    }

    /// Where a cropped thumbnail keeps the picture in view: the API's
    /// `focus`, else the centre.
    var thumbnailAnchor: UnitPoint {
        focus.flatMap(UnitPoint.init(objectPosition:)) ?? .center
    }

    /// The title in the content language, falling back as the Journey does.
    func title(in locale: ContentLocale) -> String {
        title.resolved(for: locale)?.text ?? ""
    }

    /// Whether the release cover's file comes from a store, database or
    /// collector rather than the publisher.
    var isThirdPartyCover: Bool {
        sourceKind == .thirdPartyCover || cover?.thirdParty == true
    }
}
