import Foundation
import KanoNaviCore
import Observation
import UserNotifications
import os

#if os(iOS)
    import UIKit
#endif

/// Coordinates local notification permissions, preference changes, foreground
/// baseline synchronization, calendar reminders, and background app refresh.
@Observable
final class NotificationController {
    private static let reminderIDPrefix = "kanonavi.reminder."
    private static let backgroundRefreshInterval: TimeInterval = 15 * 60
    private static let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier ?? "com.yexca.kanonavi",
        category: "notifications"
    )

    var preferences: NotificationPreferences {
        didSet {
            guard preferences != oldValue else { return }
            preferencesStore.save(preferences)
            schedulePreferenceSync()
        }
    }

    private(set) var authorizationState: NotificationAuthorizationState = .notDetermined
    private(set) var isBackgroundRefreshAvailable = true

    private let client: APIClient
    private let calendar: CalendarReader
    private let stateStore: any NotificationStateStore
    private let preferencesStore: NotificationPreferencesStore
    private let center: any UserNotificationCenterClient
    private let backgroundScheduler: any BackgroundRefreshScheduler
    private let defaults: UserDefaults

    @ObservationIgnored private var delegateProxy: NotificationCenterDelegateProxy?
    @ObservationIgnored private var latestDashboard: Dashboard?
    @ObservationIgnored private var latestCalendarEvents: [ScheduleEvent] = []
    @ObservationIgnored private var preferenceSyncTask: Task<Void, Never>?
    /// The 14-day calendar read now running, shared by every caller that asks
    /// for the same dashboard revision.
    @ObservationIgnored private var calendarRead: CalendarRead?
    /// Counts foreground snapshots so a reminder plan built from an older
    /// snapshot's calendar read is dropped once a newer snapshot arrived.
    @ObservationIgnored private var snapshotGeneration = 0
    #if DEBUG
        @ObservationIgnored private var isDebugBackgroundCheckArmed = false
    #endif

    private struct CalendarRead {
        let revision: Int?
        let task: Task<WidgetCalendarResult?, Never>
    }

    init(
        client: APIClient,
        calendar: CalendarReader,
        stateStore: any NotificationStateStore = FileNotificationStateStore(),
        preferencesStore: NotificationPreferencesStore = NotificationPreferencesStore(),
        center: any UserNotificationCenterClient = SystemUserNotificationCenterClient(),
        backgroundScheduler: any BackgroundRefreshScheduler = SystemBackgroundRefreshScheduler(),
        defaults: UserDefaults = .standard
    ) {
        self.client = client
        self.calendar = calendar
        self.stateStore = stateStore
        self.preferencesStore = preferencesStore
        self.center = center
        self.backgroundScheduler = backgroundScheduler
        self.defaults = defaults
        self.preferences = preferencesStore.load()
        backgroundScheduler.setRefreshHandler { [weak self] in
            await self?.performBackgroundRefresh()
        }
    }

    var backgroundTaskIdentifier: String {
        backgroundScheduler.taskIdentifier
    }

    /// Installs the `UNUserNotificationCenter` delegate at launch so notification
    /// taps and iOS's "Configure in Kano Navi" button route into `AppRouter`.
    func installDelegate(router: AppRouter) {
        let proxy = NotificationCenterDelegateProxy { [weak router] route in
            router?.open(route)
        }
        delegateProxy = proxy
        UNUserNotificationCenter.current().delegate = proxy
    }

    func refreshSystemStatus() async {
        authorizationState = await center.authorizationState()
        #if os(iOS)
            isBackgroundRefreshAvailable = UIApplication.shared.backgroundRefreshStatus == .available
        #endif
        updateBackgroundRefreshRegistration()
    }

    /// Toggles the master switch, requesting OS notification permission on the
    /// first enable if needed.
    func setMasterEnabled(_ enabled: Bool) async {
        guard enabled else {
            preferences.isEnabled = false
            return
        }

        authorizationState = await center.authorizationState()
        if authorizationState == .notDetermined {
            let granted = (try? await center.requestAuthorization()) ?? false
            authorizationState = await center.authorizationState()
            guard granted || authorizationState.canDeliverNotifications else {
                preferences.isEnabled = false
                return
            }
        } else if !authorizationState.canDeliverNotifications {
            // Keep the switch off while denied so the UI reflects real delivery state
            // and presents the "Open Settings" guidance.
            preferences.isEnabled = false
            return
        }

        preferences.isEnabled = true
    }

    /// Synchronizes the diff baseline from a foreground snapshot without showing
    /// duplicate immediate banners, and refreshes scheduled reminders.
    ///
    /// While notifications are on, the 14-day calendar is read from the service
    /// for each snapshot, so an entry added since the last read gets its
    /// reminder. The cached calendar stands in while that read runs and when it
    /// fails. Snapshots of one revision share a read, and a snapshot whose read
    /// finishes after a newer snapshot arrived is dropped.
    func observeForegroundSnapshot(_ dashboard: Dashboard, interfaceLocale: Locale = .current) async {
        latestDashboard = dashboard
        snapshotGeneration += 1
        let generation = snapshotGeneration
        // Start or join the read before the first suspension so concurrent
        // snapshots of one revision share it.
        let read = preferences.isEnabled ? calendarReadTask(revision: dashboard.meta.revision) : nil

        if read == nil || latestCalendarEvents.isEmpty, let cached = await cachedCalendarEvents() {
            latestCalendarEvents = cached
        }
        if let read, let fresh = await finishCalendarRead(read) {
            guard generation == snapshotGeneration else { return }
            latestCalendarEvents = fresh
        }
        guard generation == snapshotGeneration else { return }

        let existing = await stateStore.load()
        let evaluation = NotificationPlanner.evaluate(
            dashboard: dashboard,
            calendarEvents: latestCalendarEvents,
            baseline: existing,
            preferences: preferences,
            now: Date(),
            emitImmediate: false
        )
        await stateStore.save(evaluation.baseline)

        authorizationState = await center.authorizationState()
        if preferences.isEnabled, authorizationState.canDeliverNotifications {
            await syncPendingReminders(
                evaluation.reminders,
                contentLanguage: currentContentLanguage,
                interfaceLocale: interfaceLocale
            )
        }
    }

    /// Rebuilds timed reminders from a fresh read of the 14-day calendar, when
    /// the app returns to the foreground or enters the background. Does nothing
    /// before the first dashboard snapshot, which plans reminders itself.
    func refreshReminders(interfaceLocale: Locale = .current) async {
        guard preferences.isEnabled, let dashboard = latestDashboard else { return }
        let generation = snapshotGeneration
        let read = calendarReadTask(revision: dashboard.meta.revision)
        if let fresh = await finishCalendarRead(read) {
            guard generation == snapshotGeneration else { return }
            latestCalendarEvents = fresh
        }
        guard generation == snapshotGeneration else { return }

        authorizationState = await center.authorizationState()
        guard preferences.isEnabled, authorizationState.canDeliverNotifications else { return }
        await syncFromKnownEvents(interfaceLocale: interfaceLocale, readsMissingCalendar: false)
    }

    /// Rebuilds scheduled local reminders when the content or interface language changes.
    func handleLanguageChange(interfaceLocale: Locale = .current) async {
        guard preferences.isEnabled else { return }
        await syncFromKnownEvents(interfaceLocale: interfaceLocale)
    }

    /// Called when the scene enters the background: rebuilds timed reminders
    /// from the fresh calendar, then queues the next `BGAppRefreshTask`
    /// whenever immediate update alerts are enabled.
    func handleDidEnterBackground(interfaceLocale: Locale = .current) async {
        #if DEBUG
            startArmedDebugBackgroundCheck()
        #endif
        await withBackgroundExecution(named: "Rebuild reminders") {
            await refreshReminders(interfaceLocale: interfaceLocale)
            guard preferences.hasImmediateAlertsEnabled, authorizationState.canDeliverNotifications else {
                backgroundScheduler.cancelRefresh()
                return
            }
            await backgroundScheduler.scheduleNextRefresh(after: Self.backgroundRefreshInterval)
        }
    }

    /// Executes one background app refresh cycle: fetches the latest dashboard
    /// and 14-day calendar, diffs against the persisted baseline, posts matching
    /// local notifications, and updates scheduled reminders. Each step is logged
    /// under the "notifications" category for Console.
    func performBackgroundRefresh() async {
        let logger = Self.logger
        authorizationState = await center.authorizationState()
        guard preferences.isEnabled, authorizationState.canDeliverNotifications else {
            logger.info("Background check skipped: notifications are off or not authorized")
            backgroundScheduler.cancelRefresh()
            return
        }

        if preferences.hasImmediateAlertsEnabled {
            await backgroundScheduler.scheduleNextRefresh(after: Self.backgroundRefreshInterval)
        } else {
            backgroundScheduler.cancelRefresh()
        }

        guard !Task.isCancelled else { return }

        do {
            let dashboard = try await client.dashboard(days: 7)
            logger.info(
                "Background check fetched dashboard revision \(dashboard.meta.revision ?? -1, privacy: .public)"
            )
            guard !Task.isCancelled else { return }
            latestDashboard = dashboard
            do {
                let range = try await calendar.widgetRange()
                latestCalendarEvents = range.events
                logger.info(
                    "Background check read \(range.events.count, privacy: .public) calendar events (cached: \(range.isStale, privacy: .public))"
                )
            } catch {
                logger.error(
                    "Background check calendar read failed: \(String(describing: error), privacy: .public)"
                )
            }
            guard !Task.isCancelled else { return }

            let baseline = await stateStore.load()
            let evaluation = NotificationPlanner.evaluate(
                dashboard: dashboard,
                calendarEvents: latestCalendarEvents,
                baseline: baseline,
                preferences: preferences,
                now: Date(),
                emitImmediate: true
            )
            await stateStore.save(evaluation.baseline)
            logger.info(
                "Background check found \(evaluation.immediate.count, privacy: .public) immediate alerts (baseline existed: \(baseline != nil, privacy: .public))"
            )

            let language = currentContentLanguage
            let locale = Locale.current
            for item in evaluation.immediate {
                let payload = NotificationCopyFormatter.format(
                    item,
                    contentLanguage: language,
                    interfaceLocale: locale
                )
                do {
                    try await center.add(payload)
                } catch {
                    logger.error(
                        "Background check could not post \(payload.id, privacy: .public): \(String(describing: error), privacy: .public)"
                    )
                }
            }

            await syncPendingReminders(
                evaluation.reminders,
                contentLanguage: language,
                interfaceLocale: locale
            )
            logger.info(
                "Background check scheduled \(evaluation.reminders.count, privacy: .public) reminders"
            )
        } catch {
            logger.error(
                "Background check dashboard fetch failed: \(String(describing: error), privacy: .public)"
            )
        }
    }

    #if DEBUG
        /// Arms one run of `performBackgroundRefresh()` about five seconds after
        /// the app next enters the background, so a tester can watch its banners.
        func armDebugBackgroundCheck() {
            isDebugBackgroundCheckArmed = true
            Self.logger.info("Debug background check armed")
        }

        private func startArmedDebugBackgroundCheck() {
            guard isDebugBackgroundCheckArmed else { return }
            isDebugBackgroundCheckArmed = false
            Task {
                await withBackgroundExecution(named: "Debug background check") {
                    try? await Task.sleep(for: .seconds(5))
                    Self.logger.info("Debug background check running")
                    await performBackgroundRefresh()
                }
            }
        }
    #endif

    // MARK: - Internal Helpers

    private var currentContentLanguage: ContentLanguage {
        guard let raw = defaults.string(forKey: AppSettings.contentLanguageKey),
            let language = ContentLanguage(rawValue: raw)
        else {
            return .system
        }
        return language
    }

    private func schedulePreferenceSync() {
        preferenceSyncTask?.cancel()
        preferenceSyncTask = Task { [weak self] in
            guard let self else { return }
            await self.applyPreferenceChanges()
        }
    }

    private func applyPreferenceChanges() async {
        authorizationState = await center.authorizationState()
        updateBackgroundRefreshRegistration()

        guard preferences.isEnabled, authorizationState.canDeliverNotifications else {
            await clearPendingReminders()
            return
        }

        await syncFromKnownEvents(interfaceLocale: .current)
    }

    private func updateBackgroundRefreshRegistration() {
        if preferences.hasImmediateAlertsEnabled, authorizationState.canDeliverNotifications {
            Task { [backgroundScheduler] in
                await backgroundScheduler.scheduleNextRefresh(after: Self.backgroundRefreshInterval)
            }
        } else {
            backgroundScheduler.cancelRefresh()
        }
    }

    /// Starts a read of the 14-day calendar, or returns the one already running
    /// for the same dashboard revision. A running read for another revision is
    /// cancelled, since its caller's snapshot is out of date.
    private func calendarReadTask(revision: Int?) -> Task<WidgetCalendarResult?, Never> {
        if let running = calendarRead, running.revision == revision {
            return running.task
        }
        calendarRead?.task.cancel()
        let calendar = calendar
        let task = Task { try? await calendar.widgetRange() }
        calendarRead = CalendarRead(revision: revision, task: task)
        return task
    }

    /// The events of a finished calendar read, or `nil` when the service and
    /// the cache both failed.
    private func finishCalendarRead(_ task: Task<WidgetCalendarResult?, Never>) async -> [ScheduleEvent]? {
        let result = await task.value
        if calendarRead?.task == task {
            calendarRead = nil
        }
        return result?.events
    }

    private func cachedCalendarEvents() async -> [ScheduleEvent]? {
        let today = JapanDate.today
        return await calendar.cachedResult(from: today, to: today.addingDays(13))?.page.events
    }

    /// Plans reminders from the latest dashboard and calendar events.
    /// `readsMissingCalendar` reads the calendar first when none is known yet.
    private func syncFromKnownEvents(interfaceLocale: Locale, readsMissingCalendar: Bool = true) async {
        var events = latestDashboard?.events ?? []
        if readsMissingCalendar, latestCalendarEvents.isEmpty {
            let today = JapanDate.today
            if let range = try? await calendar.widgetRange(today: today) {
                latestCalendarEvents = range.events
            }
        }
        if events.isEmpty, let cachedDashboard = await client.cached(DashboardRequest(days: 7)) {
            latestDashboard = cachedDashboard
            events = cachedDashboard.events
        }

        var seenIDs = Set(events.map(\.id))
        for item in latestCalendarEvents where seenIDs.insert(item.id).inserted {
            events.append(item)
        }

        let reminders = NotificationPlanner.planReminders(
            events: events,
            preferences: preferences,
            now: Date()
        )
        await syncPendingReminders(
            reminders,
            contentLanguage: currentContentLanguage,
            interfaceLocale: interfaceLocale
        )
    }

    /// Runs `work` under a UIKit background task so it can finish after the
    /// app leaves the screen. A Mac app keeps running without a window, so
    /// there `work` simply runs.
    private func withBackgroundExecution(named name: String, _ work: () async -> Void) async {
        #if os(iOS)
            let execution = BackgroundExecution()
            execution.begin(named: name)
            await work()
            execution.end()
        #else
            await work()
        #endif
    }

    private func clearPendingReminders() async {
        let existing = await center.pendingRequestIdentifiers()
            .filter { $0.hasPrefix(Self.reminderIDPrefix) }
        center.removePendingRequests(withIdentifiers: existing)
    }

    private func syncPendingReminders(
        _ reminders: [ScheduledReminder],
        contentLanguage: ContentLanguage,
        interfaceLocale: Locale
    ) async {
        let existing = await center.pendingRequestIdentifiers()
            .filter { $0.hasPrefix(Self.reminderIDPrefix) }
        let desiredIDs = Set(reminders.map(\.id))
        let obsolete = existing.filter { !desiredIDs.contains($0) }
        center.removePendingRequests(withIdentifiers: obsolete)

        for reminder in reminders {
            guard !Task.isCancelled else { return }
            let payload = NotificationCopyFormatter.format(
                reminder,
                contentLanguage: contentLanguage,
                interfaceLocale: interfaceLocale
            )
            try? await center.add(payload)
        }
    }
}

#if os(iOS)
    /// One UIKit background task, ended once by whichever comes first: the work
    /// finishing or the system's expiration handler.
    private final class BackgroundExecution {
        private var identifier: UIBackgroundTaskIdentifier = .invalid

        func begin(named name: String) {
            identifier = UIApplication.shared.beginBackgroundTask(withName: name) { [weak self] in
                self?.end()
            }
        }

        func end() {
            guard identifier != .invalid else { return }
            UIApplication.shared.endBackgroundTask(identifier)
            identifier = .invalid
        }
    }
#endif
