import Testing

@testable import KanoNavi

/// One video plays at a time, and the audio session is held only while one
/// does.
@MainActor
struct LineBlogVideoCoordinatorTests {
    private let audio = RecordingAudioControl()
    private let coordinator: LineBlogVideoCoordinator

    init() {
        coordinator = LineBlogVideoCoordinator(audio: audio, releaseDelay: .zero)
    }

    @Test func startingAVideoTakesTheAudioSession() async {
        let video = StubVideoPlayer(coordinator: coordinator)

        await coordinator.willPlay(video)

        #expect(audio.calls == [.prepare])
        #expect(video.pauseCount == 0)
    }

    @Test func startingAnotherVideoPausesTheOneThatPlays() async {
        let first = StubVideoPlayer(coordinator: coordinator)
        let second = StubVideoPlayer(coordinator: coordinator)

        await coordinator.willPlay(first)
        await coordinator.willPlay(second)

        #expect(first.pauseCount == 1)
        #expect(second.pauseCount == 0)
    }

    @Test func switchingVideosKeepsTheAudioSession() async {
        let first = StubVideoPlayer(coordinator: coordinator)
        let second = StubVideoPlayer(coordinator: coordinator)

        await coordinator.willPlay(first)
        await coordinator.willPlay(second)
        await coordinator.release?.value

        #expect(audio.calls == [.prepare, .prepare], "the paused video's stop does not release")
    }

    @Test func stoppingTheLastVideoGivesTheAudioSessionBack() async {
        let video = StubVideoPlayer(coordinator: coordinator)

        await coordinator.willPlay(video)
        coordinator.didStop(video)
        await coordinator.release?.value

        #expect(audio.calls == [.prepare, .release])
    }

    @Test func aVideoThatIsNotPlayingDoesNotGiveTheSessionBack() async {
        let playing = StubVideoPlayer(coordinator: coordinator)
        let other = StubVideoPlayer(coordinator: coordinator)

        await coordinator.willPlay(playing)
        coordinator.didStop(other)

        #expect(coordinator.release == nil)
        #expect(audio.calls == [.prepare])
    }

    @Test func resumingBeforeTheSessionIsGivenBackKeepsIt() async {
        let slow = LineBlogVideoCoordinator(audio: audio, releaseDelay: .seconds(60))
        let video = StubVideoPlayer(coordinator: slow)

        await slow.willPlay(video)
        slow.didStop(video)
        let pending = slow.release
        slow.didResume(video)
        await pending?.value

        #expect(slow.release == nil)
        #expect(audio.calls == [.prepare], "a pause followed at once by play releases nothing")
    }

    @Test func resumingFromThePlayersOwnControlsPausesTheOther() async {
        let first = StubVideoPlayer(coordinator: coordinator)
        let second = StubVideoPlayer(coordinator: coordinator)

        await coordinator.willPlay(first)
        coordinator.didResume(second)

        #expect(first.pauseCount == 1)
    }

    @Test func stoppingTwiceGivesTheSessionBackOnce() async {
        let video = StubVideoPlayer(coordinator: coordinator)

        await coordinator.willPlay(video)
        coordinator.didStop(video)
        coordinator.didStop(video)
        await coordinator.release?.value

        #expect(audio.calls == [.prepare, .release])
    }
}
