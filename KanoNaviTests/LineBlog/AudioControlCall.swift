/// One request the videos made of the audio session.
nonisolated enum AudioControlCall: Equatable, Sendable {
    case prepare
    case release
}
