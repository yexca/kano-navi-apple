import Foundation
import Testing

@testable import KanoNaviCore

struct ServerCheckTests {
    let baseURL: URL

    init() throws {
        baseURL = try #require(URL(string: "https://kano.example.com"))
    }

    private func dashboardFixture() throws -> Data {
        let url = try #require(Bundle.module.url(forResource: "dashboard", withExtension: "json"))
        return try Data(contentsOf: url)
    }

    @Test func acceptsAServiceThatReturnsTheDashboard() async throws {
        let transport = SequenceTransport([
            .success(TransportResponse(data: try dashboardFixture(), statusCode: 200, headers: [:]))
        ])

        try await ServerCheck.verify(baseURL, transport: transport)

        let request = try #require(await transport.requests.first)
        #expect(request.url?.absoluteString == "https://kano.example.com/api/dashboard?days=1")
    }

    @Test func noResponseIsUnreachable() async {
        let transport = SequenceTransport([.failure(URLError(.cannotFindHost))])
        await #expect(throws: ServerCheckError.unreachable) {
            try await ServerCheck.verify(baseURL, transport: transport)
        }
    }

    @Test(arguments: [
        TransportResponse(data: Data("<html></html>".utf8), statusCode: 200, headers: [:]),
        TransportResponse(data: Data(), statusCode: 404, headers: [:]),
    ])
    func aResponseThatIsNotADashboardIsIncompatible(response: TransportResponse) async {
        let transport = SequenceTransport([.success(response)])
        await #expect(throws: ServerCheckError.incompatible) {
            try await ServerCheck.verify(baseURL, transport: transport)
        }
    }
}
