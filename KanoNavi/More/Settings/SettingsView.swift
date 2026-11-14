import KanoNaviCore
import SwiftUI
import UIKit

/// The Notifications link, the content language menu, and a link to the
/// system's per-app language setting for the interface.
struct SettingsView: View {
    @AppStorage(AppSettings.contentLanguageKey) private var contentLanguage: ContentLanguage = .system
    @Environment(NotificationController.self) private var notifications: NotificationController?
    @Environment(\.openURL) private var openURL
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

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

    var body: some View {
        Form {
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

            Section {
                // A menu's label and value stack and clip at accessibility
                // sizes, so there the choices open as a list instead.
                if dynamicTypeSize.isAccessibilitySize {
                    contentLanguagePicker
                        .pickerStyle(.navigationLink)
                } else {
                    contentLanguagePicker
                        .pickerStyle(.menu)
                }

                Button {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
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
                .accessibilityHint(Text(.More.settingsAppLanguageHint))
            }
        }
        .navigationTitle(.More.moreSettings)
        .navigationBarTitleDisplayMode(.inline)
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
