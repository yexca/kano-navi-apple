import Foundation
import KanoNaviCore
import Testing

@testable import KanoNavi

/// Which pictures the viewer pages through, and where an image says it came from.
struct WorksGalleryTests {
    @Test func aFileShownInSeveralPlacesIsOnePicture() throws {
        let cover = WorksFixtures.image("cover-a.jpg")
        let release = try WorksFixtures.release(
            id: "r", date: "2020-03-04", covers: [cover, WorksFixtures.image("cover-b.jpg")],
            disc: WorksFixtures.image("disc1.png"), discs: [WorksFixtures.discImage(1, "disc1.png")],
            editions: [
                WorksFixtures.edition(
                    covers: [cover], bonusImages: [WorksFixtures.image("bonus.jpg")],
                    storeBonuses: [
                        WorksFixtures.storeBonus("Store A", images: [WorksFixtures.image("store-a.jpg")])
                    ],
                    discs: [WorksFixtures.discImage(1, "disc1.png"), WorksFixtures.discImage(2, "disc2.png")])
            ],
            storeBonuses: [WorksFixtures.storeBonus("Store B", images: [WorksFixtures.image("store-b.jpg")])])

        let gallery = WorksGallery(release: release)

        #expect(
            gallery.pictures.map(\.image.url.lastPathComponent) == [
                "cover-a.jpg", "cover-b.jpg", "disc1.png", "bonus.jpg", "disc2.png", "store-a.jpg",
                "store-b.jpg",
            ])
    }

    @Test func findsThePictureOfAnImageByItsFile() throws {
        let release = try WorksFixtures.release(
            id: "r", date: "2020-03-04", covers: [WorksFixtures.image("cover-a.jpg", caption: "First cover")],
            editions: [
                WorksFixtures.edition(covers: [WorksFixtures.image("cover-a.jpg", caption: "Edition cover")])
            ])
        let gallery = WorksGallery(release: release)

        let picture = try #require(gallery.picture(for: release.editions[0].covers[0]))

        #expect(picture.id == "https://example.com/media/works/cover-a.jpg")
        #expect(picture.image.caption?.en == "First cover")
        #expect(picture.source == MediaImageSource(url: picture.image.url, width: 600, height: 600))
    }

    @Test func discPhotosAddTheShelfsDiscOnlyWhenItIsAnotherFile() throws {
        let same = try WorksFixtures.release(
            id: "r", date: "2020-03-04", disc: WorksFixtures.image("disc1.png"),
            discs: [WorksFixtures.discImage(1, "disc1.png")])
        let alone = try WorksFixtures.release(
            id: "s", date: "2020-03-04", disc: WorksFixtures.image("shelf.png"))

        #expect(WorksGallery.discPhotos(of: same).map(\.url.lastPathComponent) == ["disc1.png"])
        #expect(WorksGallery.discPhotos(of: alone).map(\.url.lastPathComponent) == ["shelf.png"])
    }

    @Test func aReleaseWithoutImagesHasAnEmptyGallery() throws {
        let release = try WorksFixtures.release(id: "r", date: "2020-03-04")

        #expect(WorksGallery(release: release).pictures.isEmpty)
    }

    @Test func provenanceNamesThePageByItsHost() throws {
        let image = try WorksFixtures.decode(
            WorksImage.self, WorksFixtures.image("a.jpg", sourceURL: "https://www.example.com/release/1"))

        let provenance = try #require(WorksImageProvenance(image))

        #expect(
            provenance
                == .page(try #require(URL(string: "https://www.example.com/release/1")), host: "example.com"))
        #expect(provenance.name == "example.com")
    }

    @Test func provenanceNamesTheSiteWhenThereIsNoPage() throws {
        let labelled = try WorksFixtures.decode(
            WorksImage.self, WorksFixtures.image("a.jpg", sourceLabel: "Example Shop"))
        let bare = try WorksFixtures.decode(WorksImage.self, WorksFixtures.image("b.jpg"))
        let empty = try WorksFixtures.decode(WorksImage.self, WorksFixtures.image("c.jpg", sourceLabel: ""))

        #expect(WorksImageProvenance(labelled) == .site("Example Shop"))
        #expect(WorksImageProvenance(bare) == nil)
        #expect(WorksImageProvenance(empty) == nil)
    }

    @Test func captionFollowsTheContentLanguageAndFallsBack() throws {
        var image = try WorksFixtures.decode(WorksImage.self, WorksFixtures.image("a.jpg"))
        #expect(WorksImageCaption.title(of: image, in: .ja) == nil)

        image.caption = LocalizedText(ja: "ジャケット", en: "Cover")
        #expect(WorksImageCaption.title(of: image, in: .ja) == "ジャケット")
        #expect(WorksImageCaption.title(of: image, in: .zhHans) == "Cover")
    }
}
