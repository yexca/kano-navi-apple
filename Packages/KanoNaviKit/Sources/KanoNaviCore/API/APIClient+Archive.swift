import Foundation

extension APIClient {
    public func journey() async throws -> JourneyResponse {
        try await send(JourneyRequest())
    }

    public func works() async throws -> WorksResponse {
        try await send(WorksRequest())
    }

    public func worksUploadList() async throws -> WorksUploadListResponse {
        try await send(WorksUploadListRequest())
    }

    public func lineBlog() async throws -> LineBlogIndexResponse {
        try await send(LineBlogIndexRequest())
    }

    public func lineBlogPost(id: String) async throws -> LineBlogPostResponse {
        try await send(LineBlogPostRequest(id: id))
    }

    public func lineBlogComments(articleID: String) async throws -> LineBlogCommentsResponse {
        try await send(LineBlogCommentsRequest(articleID: articleID))
    }
}
