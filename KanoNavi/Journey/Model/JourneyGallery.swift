import KanoNaviCore

/// Every image of the Journey, once each: the milestones' images in
/// timeline order (catalogued images, then release covers, as each milestone
/// lists them), then the gallery-only images. An image listed again, such
/// as a cover two milestones share, keeps its first place.
nonisolated struct JourneyGallery: Equatable {
    let items: [JourneyMedia]

    init(_ journey: JourneyResponse) {
        var seen = Set<String>()
        var items: [JourneyMedia] = []
        for media in journey.milestones.flatMap(\.media) + journey.galleryOnly
        where seen.insert(media.id).inserted {
            items.append(media)
        }
        self.items = items
    }

    /// The images the gallery of the branch ID `branch` lists (every image
    /// for `nil`) in the category with the code `category` (every category
    /// for `nil`), in gallery order.
    func items(branch: String?, category: String?) -> [JourneyMedia] {
        items.filter { media in
            (branch.map(media.branches.contains) ?? true)
                && (category.map { $0 == media.category.rawValue } ?? true)
        }
    }

    /// How many images each branch ID's gallery lists.
    var branchCounts: [String: Int] {
        items.reduce(into: [:]) { counts, media in
            for branch in Set(media.branches) {
                counts[branch, default: 0] += 1
            }
        }
    }

    /// The categories the gallery of `branch` has, each with its count: the
    /// known categories in a fixed order, then any new code in the order it
    /// first appears. A category without images is left out.
    func categories(branch: String?) -> [JourneyCategoryCount] {
        let shown = items(branch: branch, category: nil)
        var order = JourneyCategoryCount.knownOrder
        for media in shown where order.contains(media.category) == false {
            order.append(media.category)
        }
        return order.compactMap { category in
            let count = shown.count { $0.category == category }
            return count > 0 ? JourneyCategoryCount(category: category, count: count) : nil
        }
    }
}
