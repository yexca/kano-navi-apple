import KanoNaviCore
import SwiftUI

/// Adds a server by name and address. The address must serve a Kano Navi
/// dashboard the app can read; the server is added and selected once it
/// does.
struct AddServerSheet: View {
    @Environment(AppSession.self) private var session
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var address = ""
    @State private var problem: AddServerProblem?
    @State private var checkedAddress: URL?

    private var canAdd: Bool {
        address.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false && checkedAddress == nil
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField(text: $name, prompt: Text(.More.serverNamePrompt)) {
                        Text(.More.serverName)
                    }
                    TextField(text: $address, prompt: Text(verbatim: "kano.example.com")) {
                        Text(.More.serverAddress)
                    }
                    .addressEntry()
                    .onSubmit(add)
                } footer: {
                    if let problem {
                        Label {
                            Text(problem.message)
                        } icon: {
                            Image(systemName: "exclamationmark.triangle.fill")
                        }
                        .foregroundStyle(.red)
                    } else {
                        Text(.More.serverAddressFooter)
                    }
                }
            }
            .formStyle(.grouped)
            .disabled(checkedAddress != nil)
            .navigationTitle(.More.serverAdd)
            .inlineNavigationTitle()
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(role: .cancel) {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    if checkedAddress != nil {
                        ProgressView()
                            .accessibilityLabel(Text(.More.serverChecking))
                    } else {
                        Button(role: .confirm, action: add)
                            .disabled(canAdd == false)
                    }
                }
            }
        }
        .sheetFormWidth()
        .onChange(of: address) {
            problem = nil
        }
        // Checking the address runs while the sheet is up; closing the sheet
        // cancels it.
        .task(id: checkedAddress) {
            guard let baseURL = checkedAddress else { return }
            await check(baseURL)
        }
    }

    /// Reads the typed address and starts checking it.
    private func add() {
        guard canAdd else { return }
        let baseURL: URL
        do {
            baseURL = try ServerAddress.parse(address)
        } catch {
            problem = AddServerProblem(error)
            return
        }
        guard session.servers.all.contains(where: { $0.baseURL == baseURL }) == false else {
            problem = .duplicate
            return
        }
        problem = nil
        checkedAddress = baseURL
    }

    private func check(_ baseURL: URL) async {
        do {
            try await ServerCheck.verify(baseURL)
        } catch {
            switch error {
            case .unreachable: problem = .unreachable
            case .incompatible: problem = .incompatible
            case .cancelled: return
            }
            checkedAddress = nil
            return
        }

        do {
            try session.add(name: name, baseURL: baseURL)
            dismiss()
        } catch {
            problem = .duplicate
            checkedAddress = nil
        }
    }
}
