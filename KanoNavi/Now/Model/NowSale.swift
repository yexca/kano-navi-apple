import Foundation
import KanoNaviCore

/// An item in the on-sale strip, from `projection.sales`.
struct NowSale: Equatable, Identifiable {
    struct Moment: Equatable {
        var date: JapanDate
        var time: Date?
    }

    var id: String
    var title: NowContentText
    var state: EventState
    var opens: Moment?
    var closes: Moment?

    /// The sale's opening and closing from its calendar entries, else from
    /// its stored sale window.
    init(event: ScheduleEvent) {
        id = event.id
        title = NowContentText(
            event.title, sourceLanguage: event.sourceLanguage, translations: event.translations)
        state = event.view?.state ?? .unknown("")
        let entries = event.view?.calendarEntries ?? []
        if let open = entries.first(where: { $0.saleMark == .opens }) {
            opens = Moment(date: open.startsOn, time: open.startsAt)
        } else if let window = event.saleWindow {
            opens = Moment(date: window.startsOn, time: window.startsAt)
        }
        if let close = entries.first(where: { $0.saleMark == .closes }) {
            closes = Moment(date: close.startsOn, time: close.startsAt)
        } else if let window = event.saleWindow, let endsOn = window.endsOn {
            closes = Moment(date: endsOn, time: window.endsAt)
        }
    }

    /// The projection's sale IDs joined to the snapshot's events, in API order.
    static func sales(in dashboard: Dashboard) -> [NowSale] {
        (dashboard.projection?.sales ?? []).compactMap { id in
            dashboard.event(id: id).map(NowSale.init(event:))
        }
    }
}
