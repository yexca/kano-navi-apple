import Foundation
import KanoNaviComponents
import KanoNaviCore

/// The words of a timeline item beside its cover and title, and what
/// VoiceOver reads for it.
extension VideoCard {
    /// The page the item opens: the video's own page, or with a platform
    /// chosen in the filter, its page on that platform.
    var primaryLink: NowLink? {
        links.first
    }

    /// The secondary line under the title, such as `Archive · Gameplay ·
    /// Fri, Nov 13`. The form is left out when the cover says more (a status
    /// badge, or Shorts). A video with a status gives its JST date and time,
    /// a published one its JST date.
    func metaParts(locale: Locale) -> [String] {
        var parts: [String] = []
        if status == nil, isShort == false, let formCode {
            parts.append(Self.string(DisplayCodeLabels.form(formCode), locale: locale))
        }
        if let tag {
            parts.append(Self.string(DisplayCodeLabels.tag(tag), locale: locale))
        }
        if let time {
            parts.append(
                status == nil
                    ? JSTTimeFormat.day(JapanDate.date(from: time), locale: locale)
                    : JSTTimeFormat.dateTime(time, locale: locale))
        }
        return parts
    }

    /// The meta line's parts joined as the line shows them.
    func metaLine(locale: Locale) -> String {
        metaParts(locale: locale).joined(separator: " · ")
    }

    /// What VoiceOver reads for the item: the title, its status or form, the
    /// tag, who can watch it when not everyone can, its JST date and time,
    /// and its length.
    func accessibilityLabel(title: String, locale: Locale) -> String {
        var parts = [title]
        if let status {
            parts.append(Self.string(DisplayCodeLabels.videoPhase(status.phase), locale: locale))
        } else if let formCode {
            parts.append(Self.string(DisplayCodeLabels.form(formCode), locale: locale))
        }
        if let tag {
            parts.append(Self.string(DisplayCodeLabels.tag(tag), locale: locale))
        }
        if let availability {
            parts.append(Self.string(DisplayCodeLabels.availability(availability.code), locale: locale))
        }
        if let time {
            parts.append(JSTTimeFormat.dateTime(time, locale: locale))
        }
        if let durationSeconds, durationSeconds > 0 {
            parts.append(
                Duration.seconds(durationSeconds).formatted(
                    .units(allowed: [.hours, .minutes, .seconds], width: .wide).locale(locale)))
        }
        return parts.joined(separator: ", ")
    }

    private static func string(_ resource: LocalizedStringResource, locale: Locale) -> String {
        var resource = resource
        resource.locale = locale
        return String(localized: resource)
    }
}
