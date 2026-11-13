import Foundation
import KanoNaviCore
import Observation
import UIKit
import UserNotifications

/// Coordinates local notification permissions, preference changes, foreground
/// baseline synchronization, calendar reminders, and background app refresh.
@Observable
final class NotificationController {
    private static let reminderIDPrefix = "kanonavi.reminder."
    private static let backgroundRefreshInterval: TimeInterval = 15 * 60

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
        isBackgroundRefreshAvailable = UIApplication.shared.backgroundRefreshStatus == .available
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
    func observeForegroundSnapshot(_ dashboard: Dashboard, interfaceLocale: Locale = .current) async {
        latestDashboard = dashboard
        let today = JapanDate.today
        if let cached = await calendar.cachedResult(from: today, to: today.addingDays(13)) {
            latestCalendarEvents = cached.page.events
        } else if preferences.isEnabled, latestCalendarEvents.isEmpty,
            let fresh = try? await calendar.widgetRange(today: today)
        {
            latestCalendarEvents = fresh.events
        }

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

    /// Rebuilds scheduled local reminders when the content or interface language changes.
    func handleLanguageChange(interfaceLocale: Locale = .current) async {
        guard preferences.isEnabled else { return }
        await syncFromKnownEvents(interfaceLocale: interfaceLocale)
    }

    /// Called when the scene enters the background so the next `BGAppRefreshTask`
    /// is queued whenever immediate update alerts are enabled.
    func handleDidEnterBackground() async {
        guard preferences.hasImmediateAlertsEnabled, authorizationState.canDeliverNotifications else {
            backgroundScheduler.cancelRefresh()
            return
        }
        await backgroundScheduler.scheduleNextRefresh(after: Self.backgroundRefreshInterval)
    }

    /// Executes one background app refresh cycle: fetches the latest dashboard
    /// and 14-day calendar, diffs against the persisted baseline, posts matching
    /// local notifications, and updates scheduled reminders.
    func performBackgroundRefresh() async {
        authorizationState = await center.authorizationState()
        guard preferences.isEnabled, authorizationState.canDeliverNotifications else {
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
            guard !Task.isCancelled else { return }
            let calendarEvents = (try? await calendar.widgetRange())?.events ?? []
            guard !Task.isCancelled else { return }

            let baseline = await stateStore.load()
            let evaluation = NotificationPlanner.evaluate(
                dashboard: dashboard,
                calendarEvents: calendarEvents,
                baseline: baseline,
                preferences: preferences,
                now: Date(),
                emitImmediate: true
            )
            await stateStore.save(evaluation.baseline)

            let language = currentContentLanguage
            let locale = Locale.current
            for item in evaluation.immediate {
                let payload = NotificationCopyFormatter.format(
                    item,
                    contentLanguage: language,
                    interfaceLocale: locale
                )
                try? await center.add(payload)
            }

            await syncPendingReminders(
                evaluation.reminders,
                contentLanguage: language,
                interfaceLocale: locale
            )
        } catch {
            return
        }
    }

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

    private func syncFromKnownEvents(interfaceLocale: Locale) async {
        var events = latestDashboard?.events ?? []
        if latestCalendarEvents.isEmpty {
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
