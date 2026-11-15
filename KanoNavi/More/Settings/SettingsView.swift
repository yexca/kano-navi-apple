import KanoNaviCore
import SwiftUI

/// The Notifications link, the content language menu, and a link to the
/// system's per-app language setting for the interface.
struct SettingsView: View {
    /// Whether the view is the General pane of the Mac's Settings window,
    /// which titles it General and shows the notification settings as a
    /// pane of their own instead of linking them.
    var isSettingsWindowPane = false
    @AppStorage(AppSettings.contentLanguageKey) private var contentLanguage: ContentLanguage = .system
    @Environment(NotificationController.self) private var notifications: NotificationController?
    @Environment(\.openURL) private var openURL
    #if os(iOS)
        @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    #endif

    private var contentLanguagePicker: some View {
        Picker(selection: $contentLanguage) {
            ForEach(ContentLanguageOption.all, id: \.self) { language in
                Group {
                    if let autonym = ContentLanguageOption.autonym(of: language) {
                        Text(verbatim: autonym)
                    } else {
                        Text(.More.settingsSameAsApp)
                    }
                }
                .tag(language)
            }
        } label: {
            Label {
                Text(.More.settingsContentLanguage)
            } icon: {
                Image(systemName: "character.bubble")
            }
        }
    }

    private var notificationsSection: some View {
        Section {
            NavigationLink(value: MoreDestination.notifications) {
                LabeledContent {
                    Text(notificationStatusLabel)
                        .foregroundStyle(.secondary)
                } label: {
                    Label {
                        Text(.More.settingsNotificationsRow)
                    } icon: {
                        Image(systemName: "bell.badge")
                    }
                }
            }
        }
    }

    var body: some View {
        Form {
            if !isSettingsWindowPane {
                notificationsSection
            }

            Section {
                #if os(iOS)
                    // A menu's label and value stack and clip at accessibility
                    // sizes, so there the choices open as a list instead.
                    if dynamicTypeSize.isAccessibilitySize {
                        contentLanguagePicker
                            .pickerStyle(.navigationLink)
                    } else {
                        contentLanguagePicker
                            .pickerStyle(.menu)
                    }
                #else
                    contentLanguagePicker
                        .pickerStyle(.menu)
                #endif

                Button {
                    if let url = SystemSettingsURL.appLanguage {
                        openURL(url)
                    }
                } label: {
                    LabeledContent {
                        Image(systemName: "arrow.up.forward.app")
                            .foregroundStyle(.secondary)
                            .accessibilityHidden(true)
                    } label: {
                        Label {
                            Text(.More.settingsAppLanguage)
                        } icon: {
                            Image(systemName: "globe")
                        }
                    }
                }
                // Draws the row like the menu above it, not as the gray bar
                // a Mac form gives a bordered button.
                .buttonStyle(.plain)
                .accessibilityHint(Text(.More.settingsAppLanguageHint))
            } footer: {
                Text(.More.settingsLanguageFooter)
            }
        }
        .formStyle(.grouped)
        .readableContentWidth()
        .navigationTitle(isSettingsWindowPane ? .More.settingsGeneral : .More.moreSettings)
        .inlineNavigationTitle()
        .task {
            await notifications?.refreshSystemStatus()
        }
    }

    private var notificationStatusLabel: LocalizedStringResource {
        guard let notifications else {
            return .Notifications.statusOff
        }
        if notifications.authorizationState == .denied {
            return .Notifications.statusDenied
        }
        if notifications.preferences.isEnabled,
            notifications.authorizationState.canDeliverNotifications
        {
            return .Notifications.statusOn
        }
        return .Notifications.statusOff
    }
}

#Preview {
    NavigationStack {
        SettingsView()
    }
}
