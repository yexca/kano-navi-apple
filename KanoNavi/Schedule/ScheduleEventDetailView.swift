import KanoNaviComponents
import KanoNaviCore
import SwiftUI

/// One schedule entry in full: title (with its translation mark and the
/// original wording on request), time in JST, state, type and tag, sale
/// period, platform links, whether it was auto-detected or confirmed, and the
/// original announcement. External links open with `openURL`.
struct ScheduleEventDetailView: View {
    let event: ScheduleEvent

    @AppStorage(AppSettings.contentLanguageKey) private var contentLanguage: ContentLanguage = .system
    @Environment(\.locale) private var locale
    @Environment(\.openURL) private var openURL
    @Environment(\.dismiss) private var dismiss
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @State private var showsOriginal = false

    var body: some View {
        NavigationStack {
            List {
                Section {
                    titleBlock
                }
                if saleEntries.isEmpty {
                    timeSection
                } else {
                    saleSection
                }
                platformSection
                sourceSection
            }
            .listStyle(.insetGrouped)
            .readableContentWidth()
            .navigationTitle(.Schedule.detailTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(role: .close) {
                        dismiss()
                    }
                }
            }
        }
    }

    // MARK: Title

    private var resolvedTitle: ResolvedContentText {
        event.resolvedTitle(preference: contentLanguage, interfaceLocale: locale)
    }

    private var titleBlock: some View {
        VStack(alignment: .leading, spacing: 10) {
            let title = resolvedTitle
            Text(verbatim: showsOriginal ? title.original : title.text)
                .font(.title2.weight(.bold))
                .strikethrough(event.isCancelled)
                .fixedSize(horizontal: false, vertical: true)
                .accessibilityAddTraits(.isHeader)
            if title.isTranslation {
                ViewThatFits(in: .horizontal) {
                    HStack {
                        translationMark(for: title)
                        Spacer()
                        originalToggle
                    }
                    VStack(alignment: .leading, spacing: 6) {
                        translationMark(for: title)
                        originalToggle
                    }
                }
            }
            EventChips(event: event, includesUpcomingState: true)
        }
        .padding(.vertical, 4)
    }

    @ViewBuilder
    private func translationMark(for title: ResolvedContentText) -> some View {
        if showsOriginal {
            Label(.Schedule.originalMark, systemImage: "text.quote")
                .font(.caption)
                .foregroundStyle(.secondary)
        } else {
            TranslationMark(origin: title.origin)
        }
    }

    private var originalToggle: some View {
        Button(showsOriginal ? .Schedule.showTranslation : .Schedule.showOriginal) {
            showsOriginal.toggle()
        }
        .font(.caption.weight(.semibold))
        .buttonStyle(.borderless)
    }

    // MARK: Time

    private var timeSection: some View {
        Section(.Schedule.detailTime) {
            if let start = JSTTimeFormat.entry(
                startsAt: event.startsAt, startsOn: event.startsOn, timePrecision: event.timePrecision,
                includesDate: true, locale: locale)
            {
                LabeledContent(.Schedule.detailStarts) {
                    Text(verbatim: start)
                        .monospacedDigit()
                }
            }
            if let end {
                LabeledContent(.Schedule.detailEnds) {
                    Text(verbatim: end)
                        .monospacedDigit()
                }
            }
        }
    }

    private var end: String? {
        if let endsAt = event.endsAt {
            return JSTTimeFormat.dateTime(endsAt, locale: locale)
        }
        if let endsOn = event.endsOn, endsOn != event.startsOn {
            return JSTTimeFormat.day(endsOn, locale: locale)
        }
        return nil
    }

    // MARK: Sale

    /// The entry's sale opening and close, as the server places them in the
    /// calendar.
    private var saleEntries: [CalendarEntryView] {
        event.displayCalendarEntries.filter { $0.saleMark != nil }
    }

    private var saleSection: some View {
        Section(.Schedule.detailSale) {
            ForEach(saleEntries.enumerated(), id: \.offset) { _, entry in
                LabeledContent {
                    JSTTimeLabel(entry: entry, includesDate: true)
                } label: {
                    if let mark = entry.saleMark {
                        SaleChip(mark: mark)
                    }
                }
            }
        }
    }

    // MARK: Platforms

    private var links: [(platform: EventPlatform, url: URL)] {
        (event.links ?? []).compactMap { link in link.url.map { (link.platform, $0) } }
    }

    @ViewBuilder
    private var platformSection: some View {
        let platforms = event.platforms ?? event.platform.map { [$0] } ?? []
        if links.isEmpty == false {
            Section(.Schedule.detailPlatforms) {
                ForEach(links.enumerated(), id: \.offset) { _, link in
                    Button {
                        openURL(link.url)
                    } label: {
                        HStack {
                            PlatformMark(platform: link.platform)
                            if dynamicTypeSize.isAccessibilitySize == false {
                                Spacer()
                                Image(systemName: "arrow.up.right")
                                    .foregroundStyle(.secondary)
                                    .accessibilityHidden(true)
                            }
                        }
                    }
                }
            }
        } else if platforms.isEmpty == false {
            Section(.Schedule.detailPlatforms) {
                ForEach(platforms, id: \.rawValue) { platform in
                    PlatformMark(platform: platform)
                }
            }
        }
    }

    // MARK: Source

    private var sourceSection: some View {
        Section {
            if event.isConfirmed {
                Label(.Schedule.confirmed, systemImage: "checkmark.seal.fill")
            } else {
                Label(.Schedule.autoDetected, systemImage: "wand.and.sparkles")
            }
            if let url = event.url {
                Button {
                    openURL(url)
                } label: {
                    Label(.Schedule.openOriginal, systemImage: "arrow.up.right.square")
                }
            }
        } header: {
            Text(.Schedule.detailSource)
        } footer: {
            Text(event.isConfirmed ? .Schedule.confirmedFooter : .Schedule.autoDetectedFooter)
        }
    }
}
