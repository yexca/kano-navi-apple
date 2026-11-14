import KanoNaviComponents
import KanoNaviCore
import SwiftUI

/// "Updating…" in a capsule, while the dashboard on screen is the snapshot
/// saved on this device and the first refresh reads the service.
///
/// It floats over the bottom of a list, so it moves nothing when it comes
/// and goes, and it waits a second first, so a refresh that finishes sooner
/// shows nothing at all. VoiceOver reads it as the saved copy's time.
struct NowSavedCopyNotice: View {
    let dashboard: DashboardStore

    @Environment(\.locale) private var locale
    @State private var isShown = false

    /// How long a refresh runs before the capsule appears.
    private static let delay: Duration = .seconds(1)

    var body: some View {
        let isUpdating = isUpdating
        ZStack {
            if isShown, isUpdating {
                capsule
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.2), value: isShown && isUpdating)
        .task(id: isUpdating) {
            guard isUpdating else {
                isShown = false
                return
            }
            try? await Task.sleep(for: Self.delay)
            if Task.isCancelled == false {
                isShown = true
            }
        }
    }

    private var isUpdating: Bool {
        NowNotice(source: dashboard.source, phase: dashboard.phase, isIncompatible: dashboard.isIncompatible)
            == .savedCopy(isUpdating: true)
    }

    private var capsule: some View {
        HStack(spacing: 6) {
            ProgressView()
                .controlSize(.small)
            Text(.Now.savedCopyUpdating)
        }
        .font(.footnote)
        .foregroundStyle(.secondary)
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .glassEffect(.regular, in: .capsule)
        .padding(.bottom, 8)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text(message))
        .accessibilityValue(Text(.Now.savedCopyUpdating))
    }

    private var message: LocalizedStringResource {
        guard let fetchedAt = dashboard.fetchedAt else { return .Now.savedCopy }
        return .Now.savedCopyFrom(JSTTimeFormat.dateTime(fetchedAt, locale: locale))
    }
}
