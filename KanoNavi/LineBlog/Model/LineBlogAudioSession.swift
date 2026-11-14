import AVFAudio

/// The app's audio session as the reader's videos use it.
///
/// An actor, so the two calls never overlap and run away from the main
/// actor: giving the session back can take a moment. macOS has no app
/// audio session, so there both calls do nothing.
actor LineBlogAudioSession: LineBlogAudioControl {
    /// How long to wait before trying once more to give the session back
    /// when the system still counts the paused player as running.
    private static let busyRetryDelay = Duration.seconds(1)

    /// The `playback` category is what makes a video the reader started
    /// sound with the ring switch off. The player activates the session
    /// itself when it starts.
    func prepareForPlayback() {
        #if os(iOS)
            try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .moviePlayback)
        #endif
    }

    /// Deactivates the session and tells the other apps, so music the
    /// video interrupted resumes. The category stays, for the next video.
    func releaseAfterPlayback() async {
        #if os(iOS)
            if deactivate() == false {
                try? await Task.sleep(for: Self.busyRetryDelay)
                guard Task.isCancelled == false else { return }
                _ = deactivate()
            }
        #endif
    }

    #if os(iOS)
        private func deactivate() -> Bool {
            do {
                try AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
                return true
            } catch {
                return false
            }
        }
    #endif
}
