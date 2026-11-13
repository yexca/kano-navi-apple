/// What a playing video asks of the device's audio: the session for
/// itself while it plays, and to give it back afterwards.
nonisolated protocol LineBlogAudioControl: Sendable {
    /// Called before a video starts. Makes it sound even with the ring
    /// switch off.
    func prepareForPlayback() async
    /// Called once no video is playing any more. Lets audio of other apps
    /// that the video interrupted, such as music, carry on.
    func releaseAfterPlayback() async
}
