import KanoNaviCore
import SwiftUI

/// The servers the app can read: the built-in ones, then the ones the person
/// added, which they can remove. Selecting one reads it from then on.
struct ServerSettingsView: View {
    @Environment(AppSession.self) private var session: AppSession?
    @State private var isAddingServer = false

    var body: some View {
        Form {
            if let session {
                Section {
                    ForEach(session.servers.all) { server in
                        ServerRow(server: server, isSelected: server.id == session.servers.selectedID) {
                            session.select(server.id)
                        }
                        .deleteDisabled(server.builtIn != nil)
                        .contextMenu {
                            if server.builtIn == nil {
                                Button(role: .destructive) {
                                    session.remove(server.id)
                                } label: {
                                    Label {
                                        Text(.More.serverRemove)
                                    } icon: {
                                        Image(systemName: "trash")
                                    }
                                }
                            }
                        }
                    }
                    .onDelete { offsets in
                        let servers = session.servers.all
                        for offset in offsets where servers[offset].builtIn == nil {
                            session.remove(servers[offset].id)
                        }
                    }
                } footer: {
                    Text(.More.serverFooter)
                }

                Section {
                    Button {
                        isAddingServer = true
                    } label: {
                        Label {
                            Text(.More.serverAdd)
                        } icon: {
                            Image(systemName: "plus")
                        }
                    }
                }
            }
        }
        .formStyle(.grouped)
        .readableContentWidth()
        .navigationTitle(.More.settingsServer)
        .inlineNavigationTitle()
        .sheet(isPresented: $isAddingServer) {
            AddServerSheet()
        }
    }
}
