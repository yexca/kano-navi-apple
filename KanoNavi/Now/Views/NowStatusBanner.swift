import KanoNaviComponents
import SwiftUI

/// A problem shown above the last good data, which stays on screen.
struct NowStatusBanner: View {
    let status: NowStatus
    /// Whether the data on screen is the snapshot saved on this device
    /// rather than one received since launch.
    let isSavedCopy: Bool
    /// When the data on screen was received from the service.
    let fetchedAt: Date?
    let retry: () async -> Void

    @Environment(\.locale) private var locale
    @State private var isRetrying = false

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label {
                Text(title)
                    .font(.headline)
            } icon: {
                Image(systemName: symbol)
                    .foregroundStyle(.orange)
            }
            Text(message)
            if let fetchedAt {
                Text(receivedNote(fetchedAt))
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            if status != .serviceNeedsUpdate {
                Button(.Now.retry) {
                    isRetrying = true
                    Task {
                        await retry()
                        isRetrying = false
                    }
                }
                .buttonStyle(.bordered)
                .disabled(isRetrying)
            }
        }
        .padding(.vertical, 4)
    }

    private var title: LocalizedStringResource {
        status == .serviceNeedsUpdate ? .Now.statusIncompatibleTitle : .Now.statusFailedTitle
    }

    private var symbol: String {
        switch status {
        case .serviceNeedsUpdate: "arrow.down.app"
        case .offline: "wifi.slash"
        case .serverError, .unreadable: "exclamationmark.triangle"
        }
    }

    private var message: LocalizedStringResource {
        Self.message(for: status)
    }

    private func receivedNote(_ fetchedAt: Date) -> LocalizedStringResource {
        let time = JSTTimeFormat.dateTime(fetchedAt, locale: locale)
        return isSavedCopy ? .Now.statusShowingSaved(time) : .Now.statusShowingLast(time)
    }

    static func message(for status: NowStatus) -> LocalizedStringResource {
        switch status {
        case .serviceNeedsUpdate: .Now.statusIncompatibleMessage
        case .offline: .Now.statusOffline
        case .serverError(let code): .Now.statusServerError(code)
        case .unreadable: .Now.statusUnreadable
        }
    }
}
