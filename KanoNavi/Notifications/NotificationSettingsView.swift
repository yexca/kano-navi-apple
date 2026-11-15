import KanoNaviCore
import SwiftUI

/// Configures local notification switches and timed reminders.
struct NotificationSettingsView: View {
    @Environment(NotificationController.self) private var controller: NotificationController?
    @Environment(\.openURL) private var openURL
    @Environment(\.scenePhase) private var scenePhase

    @State private var masterSwitch = false
    #if DEBUG
        @State private var isDebugCheckArmed = false
    #endif

    var body: some View {
        Group {
            if let controller {
                formContent(controller: controller)
            } else {
                ContentUnavailableView(
                    String(localized: .Notifications.screenTitle),
                    systemImage: "bell.slash"
                )
            }
        }
        .navigationTitle(.Notifications.screenTitle)
        .inlineNavigationTitle()
        .task {
            await controller?.refreshSystemStatus()
            syncMasterSwitchFromController()
        }
        .onChange(of: scenePhase) { _, phase in
            #if DEBUG
                if phase == .background {
                    isDebugCheckArmed = false
                }
            #endif
            if phase == .active {
                Task {
                    await controller?.refreshSystemStatus()
                    syncMasterSwitchFromController()
                }
            }
        }
    }

    @ViewBuilder
    private func formContent(controller: NotificationController) -> some View {
        @Bindable var controller = controller
        let isActive =
            controller.preferences.isEnabled
            && controller.authorizationState.canDeliverNotifications

        Form {
            if controller.authorizationState == .denied {
                permissionDeniedSection
            }

            Section {
                Toggle(isOn: $masterSwitch) {
                    Text(.Notifications.enableToggle)
                }
                .onChange(of: masterSwitch) { _, newValue in
                    guard newValue != isActive else { return }
                    Task {
                        await controller.setMasterEnabled(newValue)
                        syncMasterSwitchFromController()
                    }
                }
                .onChange(of: isActive, initial: true) { _, active in
                    if masterSwitch != active {
                        masterSwitch = active
                    }
                }
            } footer: {
                Text(.Notifications.enableFooter)
            }

            if isActive, !controller.isBackgroundRefreshAvailable,
                controller.preferences.hasImmediateAlertsEnabled
            {
                backgroundRefreshNoticeSection
            }

            if isActive {
                liveSection(controller: controller)
                postsSection(controller: controller)
                videosSection(controller: controller)
                scheduleSection(controller: controller)
                remindersSection(controller: controller)
                membersSection(controller: controller)
                #if DEBUG
                    debugSection(controller: controller)
                #endif
            }
        }
        .formStyle(.grouped)
        .readableContentWidth()
    }

    private var permissionDeniedSection: some View {
        Section {
            VStack(alignment: .leading, spacing: 8) {
                Label {
                    Text(.Notifications.permissionDeniedTitle)
                        .font(.subheadline.weight(.semibold))
                } icon: {
                    Image(systemName: "bell.slash.fill")
                        .foregroundStyle(.orange)
                }

                Text(.Notifications.permissionDeniedMessage)
                    .font(.footnote)
                    .foregroundStyle(.secondary)

                Button {
                    openAppNotificationSettings()
                } label: {
                    Text(.Notifications.openSystemSettings)
                }
                .buttonStyle(.borderless)
            }
            .padding(.vertical, 4)
        }
    }

    private var backgroundRefreshNoticeSection: some View {
        Section {
            Label {
                Text(.Notifications.backgroundRefreshDisabledMessage)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            } icon: {
                Image(systemName: "arrow.clockwise.circle")
                    .foregroundStyle(.secondary)
            }
        }
    }

    private func liveSection(controller: NotificationController) -> some View {
        @Bindable var controller = controller
        return Section {
            Toggle(isOn: $controller.preferences.notifyLiveNow) {
                Text(.Notifications.liveNowToggle)
            }
        } header: {
            Text(.Notifications.liveSectionHeader)
        } footer: {
            Text(.Notifications.liveSectionFooter)
        }
    }

    private func postsSection(controller: NotificationController) -> some View {
        @Bindable var controller = controller
        return Section {
            Toggle(isOn: $controller.preferences.posts.ownXPosts) {
                Text(.Notifications.postsOwnX)
            }
            Toggle(isOn: $controller.preferences.posts.bilibiliPosts) {
                Text(.Notifications.postsBilibili)
            }
            Toggle(isOn: $controller.preferences.posts.promotedPosts) {
                Text(.Notifications.postsPromoted)
            }
        } header: {
            Text(.Notifications.postsSectionHeader)
        } footer: {
            Text(.Notifications.postsSectionFooter)
        }
    }

    private func videosSection(controller: NotificationController) -> some View {
        @Bindable var controller = controller
        return Section {
            Toggle(isOn: $controller.preferences.videos.works) {
                Text(.Notifications.videosWorks)
            }
            Toggle(isOn: $controller.preferences.videos.shorts) {
                Text(.Notifications.videosShorts)
            }
            Toggle(isOn: $controller.preferences.videos.archives) {
                Text(.Notifications.videosArchives)
            }
        } header: {
            Text(.Notifications.videosSectionHeader)
        } footer: {
            Text(.Notifications.videosSectionFooter)
        }
    }

    private func scheduleSection(controller: NotificationController) -> some View {
        @Bindable var controller = controller
        let anyScheduleAlert =
            controller.preferences.schedule.newEvents
            || controller.preferences.schedule.cancellationsAndChanges
        return Section {
            Toggle(isOn: $controller.preferences.schedule.newEvents) {
                Text(.Notifications.scheduleNewEvents)
            }
            Toggle(isOn: $controller.preferences.schedule.cancellationsAndChanges) {
                Text(.Notifications.scheduleChanges)
            }
            if anyScheduleAlert {
                Toggle(isOn: $controller.preferences.schedule.includesStreams) {
                    Text(.Notifications.scheduleCategoryStreams)
                }
                Toggle(isOn: $controller.preferences.schedule.includesEvents) {
                    Text(.Notifications.scheduleCategoryEvents)
                }
                Toggle(isOn: $controller.preferences.schedule.includesReleases) {
                    Text(.Notifications.scheduleCategoryReleases)
                }
                Toggle(isOn: $controller.preferences.schedule.includesSales) {
                    Text(.Notifications.scheduleCategorySales)
                }
                Toggle(isOn: $controller.preferences.schedule.confirmedOnly) {
                    Text(.Notifications.scheduleConfirmedOnly)
                }
            }
        } header: {
            Text(.Notifications.scheduleSectionHeader)
        } footer: {
            Text(.Notifications.scheduleSectionFooter)
        }
    }

    private func remindersSection(controller: NotificationController) -> some View {
        @Bindable var controller = controller
        return Section {
            Picker(selection: $controller.preferences.eventReminderLead) {
                ForEach(EventReminderLead.allCases, id: \.self) { option in
                    Text(eventLeadLabel(option))
                        .tag(option)
                }
            } label: {
                Text(.Notifications.reminderEventStartPicker)
            }

            Toggle(isOn: $controller.preferences.notifySaleOpens) {
                Text(.Notifications.reminderSaleOpensToggle)
            }

            Picker(selection: $controller.preferences.saleCloseLead) {
                ForEach(SaleCloseReminderLead.allCases, id: \.self) { option in
                    Text(saleCloseLeadLabel(option))
                        .tag(option)
                }
            } label: {
                Text(.Notifications.reminderSaleClosesPicker)
            }
        } header: {
            Text(.Notifications.remindersSectionHeader)
        } footer: {
            Text(.Notifications.remindersSectionFooter)
        }
    }

    private func membersSection(controller: NotificationController) -> some View {
        @Bindable var controller = controller
        return Section {
            Toggle(isOn: $controller.preferences.includeMembersOnly) {
                Text(.Notifications.membersIncludeToggle)
            }
        } header: {
            Text(.Notifications.membersSectionHeader)
        } footer: {
            Text(.Notifications.membersSectionFooter)
        }
    }

    #if DEBUG
        /// Runs the background check shortly after the app leaves the screen.
        /// Debug builds only, so its text stays out of the String Catalog.
        private func debugSection(controller: NotificationController) -> some View {
            Section {
                Button {
                    controller.armDebugBackgroundCheck()
                    isDebugCheckArmed = true
                } label: {
                    LabeledContent {
                        if isDebugCheckArmed {
                            Image(systemName: "checkmark")
                                .accessibilityLabel(Text(verbatim: "Armed"))
                        }
                    } label: {
                        Text(verbatim: "Run Background Check (Debug)")
                    }
                }
            } footer: {
                Text(verbatim: "Runs 5 seconds after you leave the app.")
            }
        }
    #endif

    private func eventLeadLabel(_ lead: EventReminderLead) -> LocalizedStringResource {
        switch lead {
        case .off: .Notifications.reminderLeadOff
        case .atStart: .Notifications.reminderLeadAtStart
        case .tenMinutes: .Notifications.reminderLead10M
        case .thirtyMinutes: .Notifications.reminderLead30M
        }
    }

    private func saleCloseLeadLabel(_ lead: SaleCloseReminderLead) -> LocalizedStringResource {
        switch lead {
        case .off: .Notifications.saleCloseLeadOff
        case .oneHour: .Notifications.saleCloseLead1H
        case .sixHours: .Notifications.saleCloseLead6H
        case .twentyFourHours: .Notifications.saleCloseLead24H
        }
    }

    private func syncMasterSwitchFromController() {
        guard let controller else { return }
        let effective =
            controller.preferences.isEnabled
            && controller.authorizationState.canDeliverNotifications
        if masterSwitch != effective {
            masterSwitch = effective
        }
    }

    private func openAppNotificationSettings() {
        if let url = SystemSettingsURL.notifications {
            openURL(url)
        }
    }
}

#Preview {
    let client = APIClient(configuration: .main, cache: MemoryResponseCache())
    let controller = NotificationController(
        client: client,
        calendar: CalendarReader(client: client),
        stateStore: MemoryNotificationStateStore()
    )
    NavigationStack {
        NotificationSettingsView()
    }
    .environment(controller)
}
