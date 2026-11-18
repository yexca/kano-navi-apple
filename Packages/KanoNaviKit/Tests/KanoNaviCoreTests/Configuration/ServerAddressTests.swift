import Foundation
import Testing

@testable import KanoNaviCore

struct ServerAddressTests {
    @Test(arguments: [
        ("kano.example.com", "https://kano.example.com"),
        ("  https://Kano.Example.com/  ", "https://kano.example.com"),
        ("HTTPS://kano.example.com", "https://kano.example.com"),
        ("kano.example.com:8443", "https://kano.example.com:8443"),
        ("https://example.org/kano/", "https://example.org/kano"),
    ])
    func readsAnHTTPSOrigin(input: String, expected: String) throws {
        let url = try ServerAddress.parse(input)
        #expect(url.absoluteString == expected)
    }

    @Test func rejectsAnEmptyAddress() {
        #expect(throws: ServerAddressError.empty) {
            try ServerAddress.parse("   ")
        }
    }

    @Test(arguments: ["http://kano.example.com", "ftp://kano.example.com"])
    func rejectsASchemeOtherThanHTTPS(input: String) {
        #expect(throws: ServerAddressError.notHTTPS) {
            try ServerAddress.parse(input)
        }
    }

    @Test(arguments: [
        "https://",
        "visitor@kano.example.com",
        "https://kano.example.com/?days=3",
        "https://kano.example.com/#top",
        "kano example.com",
    ])
    func rejectsAnAddressThatIsNotAnOrigin(input: String) {
        #expect(throws: ServerAddressError.invalid) {
            try ServerAddress.parse(input)
        }
    }

    @Test(arguments: [
        ("https://kano.example.com", "kano.example.com"),
        ("https://kano.example.com:8443", "kano.example.com:8443"),
        ("https://example.org/kano", "example.org/kano"),
    ])
    func displaysTheAddressWithoutTheScheme(url: String, expected: String) throws {
        let url = try #require(URL(string: url))
        #expect(ServerAddress.display(url) == expected)
    }
}
