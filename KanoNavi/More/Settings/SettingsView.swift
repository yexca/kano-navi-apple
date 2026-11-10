import KanoNaviCore
import SwiftUI
import UIKit

/// The content language picker and a link to the system's per-app language
/// setting for the interface.
struct SettingsView: View {
    @AppStorage(AppSettings.contentLanguageKey) private var contentLanguage: ContentLanguage = .system
    @Environment(\.openURL) private var openURL

    var body: some View {
        Form {
            Section {
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
                    Text(.More.settingsContentLanguageHeader)
                }
                .pickerStyle(.inline)
                .labelsHidden()
            } header: {
                Text(.More.settingsContentLanguageHeader)
            } footer: {
                Text(.More.settingsContentLanguageFooter)
            }

            Section {
                Button {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        openURL(url)
                    }
                } label: {
                    Label {
                        Text(.More.settingsAppLanguageButton)
                    } icon: {
                        Image(systemName: "globe")
                    }
                }
            } header: {
                Text(.More.settingsAppLanguageHeader)
            } footer: {
                Text(.More.settingsAppLanguageFooter)
            }
        }
        .navigationTitle(.More.moreSettings)
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        SettingsView()
    }
}
