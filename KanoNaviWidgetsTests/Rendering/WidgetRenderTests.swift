import Foundation
import KanoNaviCore
import SwiftUI
import Testing
import UIKit

/// Writes contact sheets of every widget family to `KN_RENDER_DIR` for
/// visual review. Runs only when that variable is set (pass it to
/// `xcodebuild` as `TEST_RUNNER_KN_RENDER_DIR`). With `KN_RENDER_CALENDAR`
/// naming a recorded `/api/calendar` page, it also renders that data.
@MainActor
struct WidgetRenderTests {
    nonisolated private static let environment = ProcessInfo.processInfo.environment
    nonisolated private static let outputDirectory = environment["KN_RENDER_DIR"].map { URL(filePath: $0) }

    /// Point sizes of the small, medium, large, rectangular and inline
    /// families on the two reference iPhones.
    private struct Device {
        var name: String
        var small: CGSize
        var medium: CGSize
        var large: CGSize
        var rectangular: CGSize
        var inline: CGSize
    }

    private static let devices = [
        Device(
            name: "17e", small: CGSize(width: 158, height: 158), medium: CGSize(width: 338, height: 158),
            large: CGSize(width: 338, height: 354), rectangular: CGSize(width: 160, height: 72),
            inline: CGSize(width: 234, height: 26)),
        Device(
            name: "ProMax", small: CGSize(width: 170, height: 170), medium: CGSize(width: 364, height: 170),
            large: CGSize(width: 364, height: 382), rectangular: CGSize(width: 172, height: 76),
            inline: CGSize(width: 257, height: 26)),
    ]

    private static let sizes: [DynamicTypeSize] = [.large, .xxxLarge, .accessibility2]

    private enum Family: String, CaseIterable {
        case small, medium, large, rectangular, inline
    }

    @Test(.enabled(if: outputDirectory != nil))
    func renderSampleData() throws {
        let now = Date.now
        try renderSheets(named: "sample", entry: WidgetSampleData.entry(now: now, language: .system))
        var stale = WidgetSampleData.schedule(now: now, language: .ja)
        stale.isStale = true
        stale.fetchedAt = now.addingTimeInterval(-50 * 60)
        try renderSheets(named: "sample-stale-ja", entry: UpcomingEntry(date: now, content: .schedule(stale)))
        try renderSheets(named: "busy", entry: UpcomingEntry(date: now, content: .schedule(busy(now: now))))
        try renderSheets(named: "unavailable", entry: UpcomingEntry(date: now, content: .unavailable))
        let empty = WidgetSchedule(items: [], fetchedAt: now, isStale: false, nextTransitionAt: nil)
        try renderSheets(named: "empty", entry: UpcomingEntry(date: now, content: .schedule(empty)))
    }

    @Test(.enabled(if: outputDirectory != nil && environment["KN_RENDER_CALENDAR"] != nil))
    func renderRecordedBackendData() throws {
        let path = try #require(Self.environment["KN_RENDER_CALENDAR"])
        let page = try JSONDecoder.kanoNavi().decode(
            CalendarPage.self, from: Data(contentsOf: URL(filePath: path)))
        let now = Date.now
        let result = WidgetCalendarResult(
            events: page.events, calendarEntries: [], nextTransitionAt: nil, fetchedAt: now, isStale: false)
        let schedule = WidgetSchedule(result: result, language: .system, interfaceLocale: .current)
        try renderSheets(named: "backend", entry: UpcomingEntry(date: now, content: .schedule(schedule)))
    }

    /// Three long-titled entries on each of the next seven days.
    private func busy(now: Date) -> WidgetSchedule {
        let today = JapanDate.date(from: now)
        let records = (0..<7).flatMap { offset in
            (0..<3).map { index -> [String: Any] in
                let day = today.addingDays(offset)
                let start = (JapanTime.startOfDay(day) ?? now).addingTimeInterval(
                    Double(18 + index * 2) * 3600)
                return [
                    "id": "busy-\(offset)-\(index)", "source": "sample",
                    "title": "Extended anniversary celebration stream number \(index + 1)",
                    "startsOn": day.rawValue, "startsAt": start.ISO8601Format(),
                    "view": [
                        "state": "upcoming", "typeCode": index == 1 ? "member" : "stream",
                        "activityContext": "", "isWork": false,
                        "calendarEntries": [
                            [
                                "startsOn": day.rawValue, "startsAt": start.ISO8601Format(),
                                "timePrecision": "exact",
                            ]
                        ],
                    ],
                ]
            }
        }
        let result = WidgetCalendarResult(
            events: WidgetSampleData.decode(records), calendarEntries: [], nextTransitionAt: nil,
            fetchedAt: now, isStale: false)
        return WidgetSchedule(result: result, language: .en, interfaceLocale: .current)
    }

    private func renderSheets(named name: String, entry: UpcomingEntry) throws {
        let directory = try #require(Self.outputDirectory)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        for family in Family.allCases {
            let sheet = VStack(alignment: .leading, spacing: 12) {
                ForEach(Self.devices, id: \.name) { device in
                    ForEach(Self.sizes, id: \.self) { size in
                        HStack(alignment: .top, spacing: 12) {
                            ForEach([ColorScheme.light, .dark], id: \.self) { scheme in
                                tile(family: family, device: device, entry: entry)
                                    .environment(\.dynamicTypeSize, size)
                                    .environment(\.colorScheme, scheme)
                            }
                            MonochromeTile {
                                tile(family: family, device: device, entry: entry)
                            }
                            .environment(\.dynamicTypeSize, size)
                            Text(verbatim: "\(device.name) \(size)")
                                .font(.system(size: 11))
                                .foregroundStyle(.black)
                        }
                    }
                }
            }
            .padding(12)
            .background(Color(white: 0.55))
            .environment(\.locale, .current)

            let renderer = ImageRenderer(content: sheet)
            renderer.scale = 2
            let data = try #require(renderer.uiImage?.pngData())
            try data.write(to: directory.appending(path: "\(name)-\(family.rawValue).png"))
        }
    }

    @ViewBuilder
    private func tile(family: Family, device: Device, entry: UpcomingEntry) -> some View {
        switch family {
        case .small:
            HomeTile(size: device.small) { SmallUpcomingView(entry: entry) }
        case .medium:
            HomeTile(size: device.medium) { MediumUpcomingView(entry: entry) }
        case .large:
            HomeTile(size: device.large) { LargeUpcomingView(entry: entry) }
        case .rectangular:
            LockTile(size: device.rectangular) { RectangularUpcomingView(entry: entry) }
        case .inline:
            LockTile(size: device.inline) { InlineUpcomingView(entry: entry).font(.subheadline) }
        }
    }
}
