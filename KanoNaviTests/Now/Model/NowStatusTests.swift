import KanoNaviCore
import Testing

@testable import KanoNavi

@MainActor
struct NowStatusTests {
    @Test(
        arguments: [
            (DashboardPhase.idle, nil),
            (.loading, nil),
            (.refreshing, nil),
            (.failed(.offline), NowStatus.offline),
            (.failed(.http(status: 503)), .serverError(status: 503)),
            (.failed(.decoding("bad")), .unreadable),
            (.failed(.incompatible), .serviceNeedsUpdate),
            (.failed(.cancelled), nil),
        ] as [(DashboardPhase, NowStatus?)])
    func phaseMapsToStatus(phase: DashboardPhase, expected: NowStatus?) {
        #expect(NowStatus(phase: phase, isIncompatible: false) == expected)
    }

    @Test(arguments: [DashboardPhase.idle, .refreshing, .failed(.offline)])
    func incompatibleServiceWinsOverThePhase(phase: DashboardPhase) {
        #expect(NowStatus(phase: phase, isIncompatible: true) == .serviceNeedsUpdate)
    }
}
