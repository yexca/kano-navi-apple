import Foundation

public struct VideoView: Codable, Equatable, Sendable {
    public var phase: VideoPhase
    public var formCode: VideoFormCode?
    public var shelfGroup: String
    public var latestEligible: Bool
    public var focusEligible: Bool
    public var tagContext: String
    public init(
        phase: VideoPhase, formCode: VideoFormCode? = nil, shelfGroup: String, latestEligible: Bool,
        focusEligible: Bool, tagContext: String
    ) {
        self.phase = phase
        self.formCode = formCode
        self.shelfGroup = shelfGroup
        self.latestEligible = latestEligible
        self.focusEligible = focusEligible
        self.tagContext = tagContext
    }
}
